#!/usr/bin/env python3
"""
解析 DataStudio SparkSQL 文件，提取 Hive 表血缘关系，为每个 workflow 生成 Mermaid 图。
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

BASE_DIR = Path("/Users/wei.tao/Desktop/data_mart/risk_report/Workflows")

# 匹配 schema.table 格式（支持 ${VAR} 变量占位符）
# 例如: risk_report.dws_risk_id_xxx, ${SCHEMA}.dws_risk_${reg}_xxx
TABLE_TOKEN = r'(?:\$\{[^}]+\}|\w)+'
QUALIFIED_TABLE = rf'({TABLE_TOKEN}\.{TABLE_TOKEN})'


def remove_sql_comments(sql: str) -> str:
    """移除 SQL 注释（单行 -- 和多行 /* */），保留字符串内容"""
    sql = re.sub(r'/\*.*?\*/', '', sql, flags=re.DOTALL)
    sql = re.sub(r'--.*?$', '', sql, flags=re.MULTILINE)
    return sql


def normalize_table_name(name: str) -> str:
    """统一表名格式"""
    name = name.strip().strip('`').strip('"').strip("'")
    name = re.sub(r'\s+', '', name)
    return name.lower()


def is_real_table(name: str) -> bool:
    """判断是否是真实的 Hive 表（有 schema 前缀，非临时视图别名）"""
    parts = name.split('.')
    if len(parts) != 2:
        return False
    schema, table = parts
    if schema.startswith('${') or re.match(r'^[a-z_]\w*$', schema):
        return True
    return False


def extract_temp_views(sql: str) -> set:
    """提取所有临时视图名"""
    views = set()
    for m in re.finditer(
        r'create\s+or\s+replace\s+(?:temporary\s+|temp\s+)?view\s+(\w+)',
        sql, re.IGNORECASE
    ):
        views.add(m.group(1).lower())
    return views


def extract_target_tables(sql: str) -> set:
    """提取目标表"""
    targets = set()

    for m in re.finditer(
        r'insert\s+(?:overwrite|into)\s+(?:table\s+)?' + QUALIFIED_TABLE,
        sql, re.IGNORECASE
    ):
        tbl = normalize_table_name(m.group(1))
        if is_real_table(tbl):
            targets.add(tbl)

    for m in re.finditer(
        r'create\s+(?:external\s+)?table\s+(?:if\s+not\s+exists\s+)?' + QUALIFIED_TABLE,
        sql, re.IGNORECASE
    ):
        tbl = normalize_table_name(m.group(1))
        if is_real_table(tbl):
            targets.add(tbl)

    for m in re.finditer(
        r'create\s+or\s+replace\s+view\s+' + QUALIFIED_TABLE,
        sql, re.IGNORECASE
    ):
        tbl = normalize_table_name(m.group(1))
        if is_real_table(tbl):
            targets.add(tbl)

    return targets


def extract_source_tables(sql: str, temp_views: set) -> set:
    """提取来源表（FROM/JOIN 后的表名），排除临时视图和子查询"""
    sources = set()

    for m in re.finditer(
        r'(?:from|join)\s+' + QUALIFIED_TABLE,
        sql, re.IGNORECASE
    ):
        tbl = normalize_table_name(m.group(1))
        if is_real_table(tbl):
            parts = tbl.split('.')
            if parts[1] not in temp_views:
                sources.add(tbl)

    return sources


def parse_sql_file(filepath: str) -> dict:
    """解析单个 SQL 文件"""
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        raw_sql = f.read()

    cleaned = remove_sql_comments(raw_sql)
    temp_views = extract_temp_views(cleaned)
    targets = extract_target_tables(cleaned)
    sources = extract_source_tables(cleaned, temp_views)

    sources -= targets

    return {
        'targets': targets,
        'sources': sources,
        'temp_views': temp_views,
    }


def find_workflow_dirs(base: Path) -> list:
    """找到所有包含 'Data Processing' 子目录的 workflow 文件夹"""
    workflows = []
    for dp in base.rglob("Data Processing"):
        if dp.is_dir():
            sql_files = list(dp.glob("*.sql"))
            if sql_files:
                workflows.append(dp.parent)
    return sorted(set(workflows))


def sanitize_mermaid_id(name: str) -> str:
    """将表名转为合法 Mermaid 节点 ID"""
    return re.sub(r'[^a-zA-Z0-9_]', '_', name)


def short_table_label(name: str) -> str:
    """表名展示：清理变量标记"""
    return name.replace('${', '').replace('}', '').replace("'", "")


def generate_mermaid(workflow_name: str, lineage: dict) -> str:
    """生成 Mermaid 图"""
    all_sources = set()
    all_targets = set()
    edges = []

    for sql_file, info in lineage.items():
        for t in info['targets']:
            all_targets.add(t)
            for s in info['sources']:
                all_sources.add(s)
                edges.append((s, t, sql_file))

    if not edges:
        return None

    external_sources = all_sources - all_targets
    internal_tables = all_sources & all_targets
    final_targets = all_targets - all_sources

    lines = [
        f"---",
        f"title: \"{workflow_name} 表血缘关系图\"",
        f"---",
        f"graph LR",
    ]

    defined_nodes = set()

    if external_sources:
        lines.append(f"    subgraph 外部来源表")
        for s in sorted(external_sources):
            nid = sanitize_mermaid_id(s)
            label = short_table_label(s)
            lines.append(f"        {nid}[\"{label}\"]")
            defined_nodes.add(s)
        lines.append(f"    end")

    if internal_tables:
        lines.append(f"    subgraph 中间表")
        for s in sorted(internal_tables):
            nid = sanitize_mermaid_id(s)
            label = short_table_label(s)
            lines.append(f"        {nid}[\"{label}\"]")
            defined_nodes.add(s)
        lines.append(f"    end")

    if final_targets:
        lines.append(f"    subgraph 目标输出表")
        for t in sorted(final_targets):
            nid = sanitize_mermaid_id(t)
            label = short_table_label(t)
            lines.append(f"        {nid}[[\"{label}\"]]")
            defined_nodes.add(t)
        lines.append(f"    end")

    for s in all_sources | all_targets:
        if s not in defined_nodes:
            nid = sanitize_mermaid_id(s)
            label = short_table_label(s)
            lines.append(f"    {nid}[\"{label}\"]")

    seen_edges = set()
    for src, tgt, _ in edges:
        edge_key = (src, tgt)
        if edge_key not in seen_edges:
            seen_edges.add(edge_key)
            lines.append(f"    {sanitize_mermaid_id(src)} --> {sanitize_mermaid_id(tgt)}")

    return "\n".join(lines)


def main():
    workflow_dirs = find_workflow_dirs(BASE_DIR)
    print(f"共发现 {len(workflow_dirs)} 个 workflow 目录")

    results_summary = []

    for wf_dir in workflow_dirs:
        dp_dir = wf_dir / "Data Processing"
        sql_files = sorted(dp_dir.glob("*.sql"))

        wf_name = wf_dir.name
        rel_path = wf_dir.relative_to(BASE_DIR)

        lineage = {}
        for sf in sql_files:
            info = parse_sql_file(str(sf))
            lineage[sf.name] = {
                'targets': info['targets'],
                'sources': info['sources'],
            }

        mermaid_content = generate_mermaid(str(rel_path), lineage)

        if mermaid_content:
            output_file = wf_dir / "lineage.mmd"
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(mermaid_content)

            total_sources = set()
            total_targets = set()
            for info in lineage.values():
                total_sources.update(info['sources'])
                total_targets.update(info['targets'])

            results_summary.append({
                'workflow': str(rel_path),
                'sql_files': len(sql_files),
                'source_tables': len(total_sources),
                'target_tables': len(total_targets),
                'mermaid_file': str(output_file),
            })
            print(f"[OK] {rel_path}: {len(sql_files)} SQL, "
                  f"{len(total_sources)} 来源表, {len(total_targets)} 目标表 -> lineage.mmd")
        else:
            print(f"[SKIP] {rel_path}: 未找到有效血缘关系")

    summary_file = BASE_DIR / "lineage_summary.json"
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(results_summary, f, ensure_ascii=False, indent=2)
    print(f"\n汇总结果已保存到: {summary_file}")
    print(f"共生成 {len(results_summary)} 个 Mermaid 血缘图")


if __name__ == '__main__':
    main()
