-- Credit card limits risk features (Spark SQL)
-- Primary key: shopee_user_id
-- Partition: grass_date

-- drop table if exists dws_risk_br_openfinance_credit_card_limits_features_df;
CREATE TABLE IF NOT EXISTS dws_risk_br_openfinance_credit_card_limits_features_df (
    shopee_user_id                      string  comment 'shopee user id',
    cpf                                 string comment 'cpf',
    request_date                        string  comment 'request date',
    request_time                        string comment 'request timestamp',

    -- ===== Overall =====
    total_credit_limit                  double  comment 'sum of all card line amounts',
    total_used_amount                   double  comment 'sum of all card used amounts',
    overall_limit_utilization_rate      double  comment 'total_used / total_limit',
    total_card_count                    bigint  comment 'count of distinct cards across all institutions',
    avg_limit_per_card                  double  comment 'total_limit / card_count',

    -- ===== By Institution: utilization rate =====
    nubank_limit_utilization_rate       double  comment 'nubank used/limit',
    mercadopago_limit_utilization_rate  double  comment 'mercadopago used/limit',
    bb_limit_utilization_rate           double  comment 'banco do brasil used/limit',
    itau_limit_utilization_rate         double  comment 'itau used/limit',
    santander_limit_utilization_rate    double  comment 'santander used/limit',
    picpay_limit_utilization_rate       double  comment 'picpay used/limit',
    caixa_limit_utilization_rate        double  comment 'caixa used/limit',
    bradesco_limit_utilization_rate     double  comment 'bradesco used/limit',
    outros_limit_utilization_rate       double  comment 'other institutions used/limit',

    -- ===== By Institution: total credit limit =====
    nubank_total_credit_limit           double  comment 'nubank total line amount',
    mercadopago_total_credit_limit      double  comment 'mercadopago total line amount',
    bb_total_credit_limit               double  comment 'banco do brasil total line amount',
    itau_total_credit_limit             double  comment 'itau total line amount',
    santander_total_credit_limit        double  comment 'santander total line amount',
    picpay_total_credit_limit           double  comment 'picpay total line amount',
    caixa_total_credit_limit            double  comment 'caixa total line amount',
    bradesco_total_credit_limit         double  comment 'bradesco total line amount',
    outros_total_credit_limit           double  comment 'other institutions total line amount',

    -- ===== By Institution: card count =====
    nubank_card_count                   bigint  comment 'nubank card count',
    mercadopago_card_count              bigint  comment 'mercadopago card count',
    bb_card_count                       bigint  comment 'banco do brasil card count',
    itau_card_count                     bigint  comment 'itau card count',
    santander_card_count                bigint  comment 'santander card count',
    picpay_card_count                   bigint  comment 'picpay card count',
    caixa_card_count                    bigint  comment 'caixa card count',
    bradesco_card_count                 bigint  comment 'bradesco card count',
    outros_card_count                   bigint  comment 'other institutions card count',

    -- ===== By Institution: has card flag =====
    nubank_has_institution_card_flag        int comment '1 if user has nubank card',
    mercadopago_has_institution_card_flag   int comment '1 if user has mercadopago card',
    bb_has_institution_card_flag            int comment '1 if user has bb card',
    itau_has_institution_card_flag          int comment '1 if user has itau card',
    santander_has_institution_card_flag     int comment '1 if user has santander card',
    picpay_has_institution_card_flag        int comment '1 if user has picpay card',
    caixa_has_institution_card_flag         int comment '1 if user has caixa card',
    bradesco_has_institution_card_flag      int comment '1 if user has bradesco card',
    outros_has_institution_card_flag        int comment '1 if user has other institution card',

    -- ===== By Institution: flexible limit flag =====
    nubank_has_flexible_limit_card_flag         int comment '1 if nubank card has flexible limit',
    mercadopago_has_flexible_limit_card_flag    int comment '1 if mercadopago card has flexible limit',
    bb_has_flexible_limit_card_flag             int comment '1 if bb card has flexible limit',
    itau_has_flexible_limit_card_flag           int comment '1 if itau card has flexible limit',
    santander_has_flexible_limit_card_flag      int comment '1 if santander card has flexible limit',
    picpay_has_flexible_limit_card_flag         int comment '1 if picpay card has flexible limit',
    caixa_has_flexible_limit_card_flag          int comment '1 if caixa card has flexible limit',
    bradesco_has_flexible_limit_card_flag       int comment '1 if bradesco card has flexible limit',
    outros_has_flexible_limit_card_flag         int comment '1 if other institution card has flexible limit',

    -- ===== By Tier: utilization rate =====
    black_tier_card_limit_utilization_rate      double comment 'black tier used/limit',
    platinum_tier_card_limit_utilization_rate   double comment 'platinum tier used/limit',
    gold_tier_card_limit_utilization_rate       double comment 'gold tier used/limit',
    standard_tier_card_limit_utilization_rate   double comment 'standard tier used/limit',
    debit_tier_card_limit_utilization_rate      double comment 'debit tier used/limit',
    business_tier_card_limit_utilization_rate   double comment 'business tier used/limit',
    others_tier_card_limit_utilization_rate     double comment 'others tier used/limit',

    -- ===== By Tier: total limit =====
    black_tier_card_total_limit         double comment 'black tier total line amount',
    platinum_tier_card_total_limit      double comment 'platinum tier total line amount',
    gold_tier_card_total_limit          double comment 'gold tier total line amount',
    standard_tier_card_total_limit      double comment 'standard tier total line amount',
    debit_tier_card_total_limit         double comment 'debit tier total line amount',
    business_tier_card_total_limit      double comment 'business tier total line amount',
    others_tier_card_total_limit        double comment 'others tier total line amount',

    -- ===== By Tier: card count =====
    black_tier_card_count               bigint comment 'black tier card count',
    platinum_tier_card_count            bigint comment 'platinum tier card count',
    gold_tier_card_count                bigint comment 'gold tier card count',
    standard_tier_card_count            bigint comment 'standard tier card count',
    debit_tier_card_count               bigint comment 'debit tier card count',
    business_tier_card_count            bigint comment 'business tier card count',
    others_tier_card_count              bigint comment 'others tier card count',

    -- ===== Cross Institution x Tier: utilization rate =====
    nubank_black_institution_tier_limit_utilization_rate         double comment 'nubank black tier used/limit',
    nubank_platinum_institution_tier_limit_utilization_rate      double comment 'nubank platinum tier used/limit',
    nubank_gold_institution_tier_limit_utilization_rate          double comment 'nubank gold tier used/limit',
    nubank_standard_institution_tier_limit_utilization_rate      double comment 'nubank standard tier used/limit',
    nubank_debit_institution_tier_limit_utilization_rate         double comment 'nubank debit tier used/limit',
    nubank_business_institution_tier_limit_utilization_rate      double comment 'nubank business tier used/limit',
    nubank_others_institution_tier_limit_utilization_rate        double comment 'nubank others tier used/limit',
    mercadopago_black_institution_tier_limit_utilization_rate    double comment 'mercadopago black tier used/limit',
    mercadopago_platinum_institution_tier_limit_utilization_rate double comment 'mercadopago platinum tier used/limit',
    mercadopago_gold_institution_tier_limit_utilization_rate     double comment 'mercadopago gold tier used/limit',
    mercadopago_standard_institution_tier_limit_utilization_rate double comment 'mercadopago standard tier used/limit',
    mercadopago_debit_institution_tier_limit_utilization_rate    double comment 'mercadopago debit tier used/limit',
    mercadopago_business_institution_tier_limit_utilization_rate double comment 'mercadopago business tier used/limit',
    mercadopago_others_institution_tier_limit_utilization_rate   double comment 'mercadopago others tier used/limit',
    bb_black_institution_tier_limit_utilization_rate             double comment 'bb black tier used/limit',
    bb_platinum_institution_tier_limit_utilization_rate          double comment 'bb platinum tier used/limit',
    bb_gold_institution_tier_limit_utilization_rate              double comment 'bb gold tier used/limit',
    bb_standard_institution_tier_limit_utilization_rate          double comment 'bb standard tier used/limit',
    bb_debit_institution_tier_limit_utilization_rate             double comment 'bb debit tier used/limit',
    bb_business_institution_tier_limit_utilization_rate          double comment 'bb business tier used/limit',
    bb_others_institution_tier_limit_utilization_rate            double comment 'bb others tier used/limit',
    itau_black_institution_tier_limit_utilization_rate           double comment 'itau black tier used/limit',
    itau_platinum_institution_tier_limit_utilization_rate        double comment 'itau platinum tier used/limit',
    itau_gold_institution_tier_limit_utilization_rate            double comment 'itau gold tier used/limit',
    itau_standard_institution_tier_limit_utilization_rate        double comment 'itau standard tier used/limit',
    itau_debit_institution_tier_limit_utilization_rate           double comment 'itau debit tier used/limit',
    itau_business_institution_tier_limit_utilization_rate        double comment 'itau business tier used/limit',
    itau_others_institution_tier_limit_utilization_rate          double comment 'itau others tier used/limit',
    santander_black_institution_tier_limit_utilization_rate      double comment 'santander black tier used/limit',
    santander_platinum_institution_tier_limit_utilization_rate   double comment 'santander platinum tier used/limit',
    santander_gold_institution_tier_limit_utilization_rate       double comment 'santander gold tier used/limit',
    santander_standard_institution_tier_limit_utilization_rate   double comment 'santander standard tier used/limit',
    santander_debit_institution_tier_limit_utilization_rate      double comment 'santander debit tier used/limit',
    santander_business_institution_tier_limit_utilization_rate   double comment 'santander business tier used/limit',
    santander_others_institution_tier_limit_utilization_rate     double comment 'santander others tier used/limit',
    picpay_black_institution_tier_limit_utilization_rate         double comment 'picpay black tier used/limit',
    picpay_platinum_institution_tier_limit_utilization_rate      double comment 'picpay platinum tier used/limit',
    picpay_gold_institution_tier_limit_utilization_rate          double comment 'picpay gold tier used/limit',
    picpay_standard_institution_tier_limit_utilization_rate      double comment 'picpay standard tier used/limit',
    picpay_debit_institution_tier_limit_utilization_rate         double comment 'picpay debit tier used/limit',
    picpay_business_institution_tier_limit_utilization_rate      double comment 'picpay business tier used/limit',
    picpay_others_institution_tier_limit_utilization_rate        double comment 'picpay others tier used/limit',
    caixa_black_institution_tier_limit_utilization_rate          double comment 'caixa black tier used/limit',
    caixa_platinum_institution_tier_limit_utilization_rate       double comment 'caixa platinum tier used/limit',
    caixa_gold_institution_tier_limit_utilization_rate           double comment 'caixa gold tier used/limit',
    caixa_standard_institution_tier_limit_utilization_rate       double comment 'caixa standard tier used/limit',
    caixa_debit_institution_tier_limit_utilization_rate          double comment 'caixa debit tier used/limit',
    caixa_business_institution_tier_limit_utilization_rate       double comment 'caixa business tier used/limit',
    caixa_others_institution_tier_limit_utilization_rate         double comment 'caixa others tier used/limit',
    bradesco_black_institution_tier_limit_utilization_rate       double comment 'bradesco black tier used/limit',
    bradesco_platinum_institution_tier_limit_utilization_rate    double comment 'bradesco platinum tier used/limit',
    bradesco_gold_institution_tier_limit_utilization_rate        double comment 'bradesco gold tier used/limit',
    bradesco_standard_institution_tier_limit_utilization_rate    double comment 'bradesco standard tier used/limit',
    bradesco_debit_institution_tier_limit_utilization_rate       double comment 'bradesco debit tier used/limit',
    bradesco_business_institution_tier_limit_utilization_rate    double comment 'bradesco business tier used/limit',
    bradesco_others_institution_tier_limit_utilization_rate      double comment 'bradesco others tier used/limit',
    outros_black_institution_tier_limit_utilization_rate         double comment 'outros black tier used/limit',
    outros_platinum_institution_tier_limit_utilization_rate      double comment 'outros platinum tier used/limit',
    outros_gold_institution_tier_limit_utilization_rate          double comment 'outros gold tier used/limit',
    outros_standard_institution_tier_limit_utilization_rate      double comment 'outros standard tier used/limit',
    outros_debit_institution_tier_limit_utilization_rate         double comment 'outros debit tier used/limit',
    outros_business_institution_tier_limit_utilization_rate      double comment 'outros business tier used/limit',
    outros_others_institution_tier_limit_utilization_rate        double comment 'outros others tier used/limit',

    -- ===== Cross Institution x Tier: has card flag =====
    nubank_black_has_institution_tier_card_flag          int comment '1 if user has nubank black card',
    nubank_platinum_has_institution_tier_card_flag       int comment '1 if user has nubank platinum card',
    nubank_gold_has_institution_tier_card_flag           int comment '1 if user has nubank gold card',
    nubank_standard_has_institution_tier_card_flag       int comment '1 if user has nubank standard card',
    nubank_debit_has_institution_tier_card_flag          int comment '1 if user has nubank debit card',
    nubank_business_has_institution_tier_card_flag       int comment '1 if user has nubank business card',
    nubank_others_has_institution_tier_card_flag         int comment '1 if user has nubank others card',
    mercadopago_black_has_institution_tier_card_flag     int comment '1 if user has mercadopago black card',
    mercadopago_platinum_has_institution_tier_card_flag  int comment '1 if user has mercadopago platinum card',
    mercadopago_gold_has_institution_tier_card_flag      int comment '1 if user has mercadopago gold card',
    mercadopago_standard_has_institution_tier_card_flag  int comment '1 if user has mercadopago standard card',
    mercadopago_debit_has_institution_tier_card_flag     int comment '1 if user has mercadopago debit card',
    mercadopago_business_has_institution_tier_card_flag  int comment '1 if user has mercadopago business card',
    mercadopago_others_has_institution_tier_card_flag    int comment '1 if user has mercadopago others card',
    bb_black_has_institution_tier_card_flag              int comment '1 if user has bb black card',
    bb_platinum_has_institution_tier_card_flag           int comment '1 if user has bb platinum card',
    bb_gold_has_institution_tier_card_flag               int comment '1 if user has bb gold card',
    bb_standard_has_institution_tier_card_flag           int comment '1 if user has bb standard card',
    bb_debit_has_institution_tier_card_flag              int comment '1 if user has bb debit card',
    bb_business_has_institution_tier_card_flag           int comment '1 if user has bb business card',
    bb_others_has_institution_tier_card_flag             int comment '1 if user has bb others card',
    itau_black_has_institution_tier_card_flag            int comment '1 if user has itau black card',
    itau_platinum_has_institution_tier_card_flag         int comment '1 if user has itau platinum card',
    itau_gold_has_institution_tier_card_flag             int comment '1 if user has itau gold card',
    itau_standard_has_institution_tier_card_flag         int comment '1 if user has itau standard card',
    itau_debit_has_institution_tier_card_flag            int comment '1 if user has itau debit card',
    itau_business_has_institution_tier_card_flag         int comment '1 if user has itau business card',
    itau_others_has_institution_tier_card_flag           int comment '1 if user has itau others card',
    santander_black_has_institution_tier_card_flag       int comment '1 if user has santander black card',
    santander_platinum_has_institution_tier_card_flag    int comment '1 if user has santander platinum card',
    santander_gold_has_institution_tier_card_flag        int comment '1 if user has santander gold card',
    santander_standard_has_institution_tier_card_flag    int comment '1 if user has santander standard card',
    santander_debit_has_institution_tier_card_flag       int comment '1 if user has santander debit card',
    santander_business_has_institution_tier_card_flag    int comment '1 if user has santander business card',
    santander_others_has_institution_tier_card_flag      int comment '1 if user has santander others card',
    picpay_black_has_institution_tier_card_flag          int comment '1 if user has picpay black card',
    picpay_platinum_has_institution_tier_card_flag       int comment '1 if user has picpay platinum card',
    picpay_gold_has_institution_tier_card_flag           int comment '1 if user has picpay gold card',
    picpay_standard_has_institution_tier_card_flag       int comment '1 if user has picpay standard card',
    picpay_debit_has_institution_tier_card_flag          int comment '1 if user has picpay debit card',
    picpay_business_has_institution_tier_card_flag       int comment '1 if user has picpay business card',
    picpay_others_has_institution_tier_card_flag         int comment '1 if user has picpay others card',
    caixa_black_has_institution_tier_card_flag           int comment '1 if user has caixa black card',
    caixa_platinum_has_institution_tier_card_flag        int comment '1 if user has caixa platinum card',
    caixa_gold_has_institution_tier_card_flag            int comment '1 if user has caixa gold card',
    caixa_standard_has_institution_tier_card_flag        int comment '1 if user has caixa standard card',
    caixa_debit_has_institution_tier_card_flag           int comment '1 if user has caixa debit card',
    caixa_business_has_institution_tier_card_flag        int comment '1 if user has caixa business card',
    caixa_others_has_institution_tier_card_flag          int comment '1 if user has caixa others card',
    bradesco_black_has_institution_tier_card_flag        int comment '1 if user has bradesco black card',
    bradesco_platinum_has_institution_tier_card_flag     int comment '1 if user has bradesco platinum card',
    bradesco_gold_has_institution_tier_card_flag         int comment '1 if user has bradesco gold card',
    bradesco_standard_has_institution_tier_card_flag     int comment '1 if user has bradesco standard card',
    bradesco_debit_has_institution_tier_card_flag        int comment '1 if user has bradesco debit card',
    bradesco_business_has_institution_tier_card_flag     int comment '1 if user has bradesco business card',
    bradesco_others_has_institution_tier_card_flag       int comment '1 if user has bradesco others card',
    outros_black_has_institution_tier_card_flag          int comment '1 if user has outros black card',
    outros_platinum_has_institution_tier_card_flag       int comment '1 if user has outros platinum card',
    outros_gold_has_institution_tier_card_flag           int comment '1 if user has outros gold card',
    outros_standard_has_institution_tier_card_flag       int comment '1 if user has outros standard card',
    outros_debit_has_institution_tier_card_flag          int comment '1 if user has outros debit card',
    outros_business_has_institution_tier_card_flag       int comment '1 if user has outros business card',
    outros_others_has_institution_tier_card_flag         int comment '1 if user has outros others card'
)
PARTITIONED BY (grass_date string comment 'partition date')
STORED AS PARQUET
;

WITH
latest_user_row AS (
    SELECT *
    FROM (
        SELECT
            flow_no,
            shopee_user_id,
            cpf,
            request_date,
            request_time,
            data,
            ROW_NUMBER() OVER (PARTITION BY shopee_user_id ORDER BY request_time DESC) AS rn
        FROM risk.dwd_risk_br_openfinance_request_credit_card_df
        WHERE grass_date = '${ds}'
    )
    WHERE rn = 1
),

user_keys AS (
    SELECT DISTINCT
        shopee_user_id,
        cpf,
        request_date,
        request_time
    FROM latest_user_row
),

orgs_exploded AS (
    SELECT
        l.shopee_user_id,
        l.request_time,
        lower(org_item.organisation_name) AS organisation_name,
        CASE
            WHEN lower(org_item.organisation_name) IN (
                'nubank', 'mercadopago', 'itau', 'picpay', 'caixa', 'bradesco'
            ) THEN lower(org_item.organisation_name)
            WHEN lower(org_item.organisation_name) = 'bancodobrasil' THEN 'bb'
            WHEN lower(org_item.organisation_name) = 'santander-pf' THEN 'santander'
            ELSE 'outros'
        END AS institution,
        call_item.url,
        call_item.rsp AS rsp_json
    FROM latest_user_row l
    LATERAL VIEW explode(
        from_json(
            get_json_object(l.data, '$.get_open_finance_personal_credit_card_data'),
            'array<struct<organisation_name:string,data:array<struct<url:string,rsp:string>>>>'
        )
    ) org AS org_item
    LATERAL VIEW explode(org_item.data) call AS call_item
),

account_consolidated_totals AS (
    SELECT
        shopee_user_id,
        institution,
        organisation_name,
        credit_card_account_id,
        MAX(CAST(get_json_object(li.item, '$.limitAmount.amount') AS DOUBLE)) AS line_amount,
        MAX(CAST(get_json_object(li.item, '$.usedAmount.amount') AS DOUBLE)) AS used_amount,
        MAX(CASE WHEN get_json_object(li.item, '$.isLimitFlexible') = 'true' THEN 1 ELSE 0 END) AS has_flexible_limit_int
    FROM (
        SELECT
            m.shopee_user_id,
            m.institution,
            m.organisation_name,
            regexp_extract(m.url, '/accounts/([^/]+)/limits(?:\\?|$)', 1) AS credit_card_account_id,
            m.rsp_json
        FROM orgs_exploded m
        WHERE m.url LIKE '%/credit-cards-accounts/v2/accounts/%'
          AND m.url LIKE '%/limits'
    ) limits_rows
    LATERAL VIEW explode(
        from_json(
            get_json_object(limits_rows.rsp_json, '$.data'),
            'array<string>'
        )
    ) li AS item
    WHERE upper(trim(get_json_object(li.item, '$.consolidationType'))) = 'CONSOLIDADO'
        AND upper(trim(get_json_object(li.item, '$.creditLineLimitType'))) = 'LIMITE_CREDITO_TOTAL'
      -- todo currency filter
    GROUP BY shopee_user_id, institution, organisation_name, credit_card_account_id
),

account_product AS (
    SELECT
        shopee_user_id,
        institution,
        organisation_name,
        ai.creditCardAccountId AS credit_card_account_id,
        upper(trim(ai.productType)) AS product_type_raw,
        CASE
            WHEN upper(trim(ai.productType)) IN ('BLACK', 'NANQUIM', 'INFINITE') THEN 'black'
            WHEN upper(trim(ai.productType)) IN ('PLATINUM', 'GRAFITE') THEN 'platinum'
            WHEN upper(trim(ai.productType)) IN ('GOLD') THEN 'gold'
            WHEN upper(trim(ai.productType)) IN (
                'STANDARD_NACIONAL', 'STANDARD_INTERNACIONAL',
                'CLASSIC_NACIONAL', 'CLASSIC_INTERNACIONAL',
                'GREEN', 'BLUE', 'MAIS'
            ) THEN 'standard'
            WHEN upper(trim(ai.productType)) IN (
                'REDESHOP', 'MAESTRO_MASTERCARD_MAESTRO', 'CHEQUE_ELETRONICO', 'ELECTRON', 'ELETRONIC', 'BLUEBOX',
                'BASICO_NACIONAL', 'BASICO_INTERNACIONAL'
            ) THEN 'debit'
            WHEN upper(trim(ai.productType)) IN (
                'EMPRESARIAL', 'CORPORATIVO', 'COMPRAS', 'PROFISSIONAL_LIBERAL'
            ) THEN 'business'
            ELSE 'others'
        END AS tier_bucket
    FROM orgs_exploded
    LATERAL VIEW explode(
        from_json(
            get_json_object(rsp_json, '$.data'),
            'array<struct<creditCardAccountId:string,productType:string>>'
        )
    ) av AS ai
    WHERE url LIKE '%/credit-cards-accounts/v2/accounts'
    GROUP BY
        shopee_user_id,
        institution,
        organisation_name,
        ai.creditCardAccountId,
        upper(trim(ai.productType))
),

account_limits_with_tier AS (
    SELECT
        tb.shopee_user_id,
        tb.institution,
        tb.credit_card_account_id,
        tb.tier_bucket,
        t.line_amount,
        t.used_amount,
        t.has_flexible_limit_int
    FROM account_product tb
    LEFT JOIN account_consolidated_totals t
        ON  t.shopee_user_id       = tb.shopee_user_id
        AND t.institution           = tb.institution
        AND t.organisation_name     = tb.organisation_name
        AND t.credit_card_account_id = tb.credit_card_account_id
),

all_agg AS (
    SELECT
        shopee_user_id,
        

        -- ===== Overall =====
        SUM(line_amount)                                                    AS total_credit_limit,
        SUM(used_amount)                                                    AS total_used_amount,
        COUNT(DISTINCT concat_ws('|', institution, credit_card_account_id)) AS total_card_count,

        -- ===== By Institution: utilization rate =====
        SUM(CASE WHEN institution = 'nubank'      THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'nubank'      THEN line_amount ELSE 0 END), 0) AS nubank_limit_utilization_rate,
        SUM(CASE WHEN institution = 'mercadopago'  THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'mercadopago'  THEN line_amount ELSE 0 END), 0) AS mercadopago_limit_utilization_rate,
        SUM(CASE WHEN institution = 'bb'           THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'bb'           THEN line_amount ELSE 0 END), 0) AS bb_limit_utilization_rate,
        SUM(CASE WHEN institution = 'itau'         THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'itau'         THEN line_amount ELSE 0 END), 0) AS itau_limit_utilization_rate,
        SUM(CASE WHEN institution = 'santander'    THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'santander'    THEN line_amount ELSE 0 END), 0) AS santander_limit_utilization_rate,
        SUM(CASE WHEN institution = 'picpay'       THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'picpay'       THEN line_amount ELSE 0 END), 0) AS picpay_limit_utilization_rate,
        SUM(CASE WHEN institution = 'caixa'        THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'caixa'        THEN line_amount ELSE 0 END), 0) AS caixa_limit_utilization_rate,
        SUM(CASE WHEN institution = 'bradesco'     THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'bradesco'     THEN line_amount ELSE 0 END), 0) AS bradesco_limit_utilization_rate,
        SUM(CASE WHEN institution = 'outros'       THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution = 'outros'       THEN line_amount ELSE 0 END), 0) AS outros_limit_utilization_rate,

        -- ===== By Institution: total credit limit =====
        SUM(CASE WHEN institution = 'nubank'      THEN line_amount ELSE 0 END) AS nubank_total_credit_limit,
        SUM(CASE WHEN institution = 'mercadopago'  THEN line_amount ELSE 0 END) AS mercadopago_total_credit_limit,
        SUM(CASE WHEN institution = 'bb'           THEN line_amount ELSE 0 END) AS bb_total_credit_limit,
        SUM(CASE WHEN institution = 'itau'         THEN line_amount ELSE 0 END) AS itau_total_credit_limit,
        SUM(CASE WHEN institution = 'santander'    THEN line_amount ELSE 0 END) AS santander_total_credit_limit,
        SUM(CASE WHEN institution = 'picpay'       THEN line_amount ELSE 0 END) AS picpay_total_credit_limit,
        SUM(CASE WHEN institution = 'caixa'        THEN line_amount ELSE 0 END) AS caixa_total_credit_limit,
        SUM(CASE WHEN institution = 'bradesco'     THEN line_amount ELSE 0 END) AS bradesco_total_credit_limit,
        SUM(CASE WHEN institution = 'outros'       THEN line_amount ELSE 0 END) AS outros_total_credit_limit,

        -- ===== By Institution: card count =====
        COUNT(DISTINCT CASE WHEN institution = 'nubank'      THEN credit_card_account_id END) AS nubank_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'mercadopago'  THEN credit_card_account_id END) AS mercadopago_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'bb'           THEN credit_card_account_id END) AS bb_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'itau'         THEN credit_card_account_id END) AS itau_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'santander'    THEN credit_card_account_id END) AS santander_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'picpay'       THEN credit_card_account_id END) AS picpay_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'caixa'        THEN credit_card_account_id END) AS caixa_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'bradesco'     THEN credit_card_account_id END) AS bradesco_card_count,
        COUNT(DISTINCT CASE WHEN institution = 'outros'       THEN credit_card_account_id END) AS outros_card_count,

        -- ===== By Institution: flexible limit flag =====
        MAX(CASE WHEN institution = 'nubank'      THEN has_flexible_limit_int ELSE 0 END) AS nubank_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'mercadopago'  THEN has_flexible_limit_int ELSE 0 END) AS mercadopago_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'bb'           THEN has_flexible_limit_int ELSE 0 END) AS bb_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'itau'         THEN has_flexible_limit_int ELSE 0 END) AS itau_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'santander'    THEN has_flexible_limit_int ELSE 0 END) AS santander_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'picpay'       THEN has_flexible_limit_int ELSE 0 END) AS picpay_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'caixa'        THEN has_flexible_limit_int ELSE 0 END) AS caixa_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'bradesco'     THEN has_flexible_limit_int ELSE 0 END) AS bradesco_has_flexible_limit_card_flag,
        MAX(CASE WHEN institution = 'outros'       THEN has_flexible_limit_int ELSE 0 END) AS outros_has_flexible_limit_card_flag,

        -- ===== By Tier: total limit & used amount =====
        SUM(CASE WHEN tier_bucket = 'black'    THEN line_amount ELSE 0 END) AS black_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'black'    THEN used_amount ELSE 0 END) AS black_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'platinum' THEN line_amount ELSE 0 END) AS platinum_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'platinum' THEN used_amount ELSE 0 END) AS platinum_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'gold'     THEN line_amount ELSE 0 END) AS gold_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'gold'     THEN used_amount ELSE 0 END) AS gold_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'standard' THEN line_amount ELSE 0 END) AS standard_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'standard' THEN used_amount ELSE 0 END) AS standard_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'debit'    THEN line_amount ELSE 0 END) AS debit_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'debit'    THEN used_amount ELSE 0 END) AS debit_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'business' THEN line_amount ELSE 0 END) AS business_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'business' THEN used_amount ELSE 0 END) AS business_tier_used_amount,
        SUM(CASE WHEN tier_bucket = 'others'   THEN line_amount ELSE 0 END) AS others_tier_total_limit,
        SUM(CASE WHEN tier_bucket = 'others'   THEN used_amount ELSE 0 END) AS others_tier_used_amount,

        -- ===== By Tier: card count =====
        COUNT(DISTINCT CASE WHEN tier_bucket = 'black'    THEN concat_ws('|', institution, credit_card_account_id) END) AS black_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'platinum' THEN concat_ws('|', institution, credit_card_account_id) END) AS platinum_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'gold'     THEN concat_ws('|', institution, credit_card_account_id) END) AS gold_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'standard' THEN concat_ws('|', institution, credit_card_account_id) END) AS standard_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'debit'    THEN concat_ws('|', institution, credit_card_account_id) END) AS debit_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'business' THEN concat_ws('|', institution, credit_card_account_id) END) AS business_tier_card_count,
        COUNT(DISTINCT CASE WHEN tier_bucket = 'others'   THEN concat_ws('|', institution, credit_card_account_id) END) AS others_tier_card_count,

        -- ===== Cross Institution x Tier: utilization rate =====
        SUM(CASE WHEN institution='nubank' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS nubank_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS nubank_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS nubank_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS nubank_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS nubank_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS nubank_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='nubank' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='nubank' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS nubank_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS mercadopago_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS mercadopago_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS mercadopago_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS mercadopago_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS mercadopago_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS mercadopago_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='mercadopago' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='mercadopago' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS mercadopago_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS bb_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS bb_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS bb_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS bb_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS bb_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS bb_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bb' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bb' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS bb_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS itau_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS itau_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS itau_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS itau_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS itau_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS itau_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='itau' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='itau' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS itau_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS santander_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS santander_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS santander_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS santander_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS santander_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS santander_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='santander' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='santander' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS santander_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS picpay_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS picpay_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS picpay_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS picpay_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS picpay_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS picpay_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='picpay' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='picpay' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS picpay_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS caixa_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS caixa_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS caixa_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS caixa_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS caixa_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS caixa_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='caixa' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='caixa' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS caixa_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS bradesco_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS bradesco_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS bradesco_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS bradesco_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS bradesco_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS bradesco_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='bradesco' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='bradesco' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS bradesco_others_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='black' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='black' THEN line_amount ELSE 0 END), 0) AS outros_black_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='platinum' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='platinum' THEN line_amount ELSE 0 END), 0) AS outros_platinum_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='gold' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='gold' THEN line_amount ELSE 0 END), 0) AS outros_gold_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='standard' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='standard' THEN line_amount ELSE 0 END), 0) AS outros_standard_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='debit' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='debit' THEN line_amount ELSE 0 END), 0) AS outros_debit_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='business' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='business' THEN line_amount ELSE 0 END), 0) AS outros_business_institution_tier_limit_utilization_rate,
        SUM(CASE WHEN institution='outros' AND tier_bucket='others' THEN used_amount ELSE 0 END) / NULLIF(SUM(CASE WHEN institution='outros' AND tier_bucket='others' THEN line_amount ELSE 0 END), 0) AS outros_others_institution_tier_limit_utilization_rate,

        -- ===== Cross Institution x Tier: has card flag =====
        MAX(CASE WHEN institution='nubank' AND tier_bucket='black' THEN 1 ELSE 0 END) AS nubank_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS nubank_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS nubank_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS nubank_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS nubank_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='business' THEN 1 ELSE 0 END) AS nubank_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='nubank' AND tier_bucket='others' THEN 1 ELSE 0 END) AS nubank_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='black' THEN 1 ELSE 0 END) AS mercadopago_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS mercadopago_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS mercadopago_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS mercadopago_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS mercadopago_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='business' THEN 1 ELSE 0 END) AS mercadopago_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='mercadopago' AND tier_bucket='others' THEN 1 ELSE 0 END) AS mercadopago_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='black' THEN 1 ELSE 0 END) AS bb_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS bb_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS bb_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS bb_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS bb_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='business' THEN 1 ELSE 0 END) AS bb_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bb' AND tier_bucket='others' THEN 1 ELSE 0 END) AS bb_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='black' THEN 1 ELSE 0 END) AS itau_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS itau_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS itau_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS itau_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS itau_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='business' THEN 1 ELSE 0 END) AS itau_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='itau' AND tier_bucket='others' THEN 1 ELSE 0 END) AS itau_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='black' THEN 1 ELSE 0 END) AS santander_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS santander_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS santander_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS santander_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS santander_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='business' THEN 1 ELSE 0 END) AS santander_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='santander' AND tier_bucket='others' THEN 1 ELSE 0 END) AS santander_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='black' THEN 1 ELSE 0 END) AS picpay_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS picpay_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS picpay_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS picpay_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS picpay_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='business' THEN 1 ELSE 0 END) AS picpay_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='picpay' AND tier_bucket='others' THEN 1 ELSE 0 END) AS picpay_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='black' THEN 1 ELSE 0 END) AS caixa_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS caixa_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS caixa_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS caixa_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS caixa_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='business' THEN 1 ELSE 0 END) AS caixa_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='caixa' AND tier_bucket='others' THEN 1 ELSE 0 END) AS caixa_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='black' THEN 1 ELSE 0 END) AS bradesco_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS bradesco_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS bradesco_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS bradesco_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS bradesco_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='business' THEN 1 ELSE 0 END) AS bradesco_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='bradesco' AND tier_bucket='others' THEN 1 ELSE 0 END) AS bradesco_others_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='black' THEN 1 ELSE 0 END) AS outros_black_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='platinum' THEN 1 ELSE 0 END) AS outros_platinum_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='gold' THEN 1 ELSE 0 END) AS outros_gold_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='standard' THEN 1 ELSE 0 END) AS outros_standard_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='debit' THEN 1 ELSE 0 END) AS outros_debit_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='business' THEN 1 ELSE 0 END) AS outros_business_has_institution_tier_card_flag,
        MAX(CASE WHEN institution='outros' AND tier_bucket='others' THEN 1 ELSE 0 END) AS outros_others_has_institution_tier_card_flag

    FROM account_limits_with_tier
    GROUP BY shopee_user_id
)

INSERT OVERWRITE TABLE dws_risk_br_openfinance_credit_card_limits_features_df PARTITION (grass_date = '${ds}')
SELECT
    k.shopee_user_id,
    k.cpf,
    k.request_date,
    k.request_time,
    
    -- ===== Overall =====
    COALESCE(a.total_credit_limit, 0)  AS total_credit_limit,
    COALESCE(a.total_used_amount, 0)   AS total_used_amount,
    COALESCE(a.total_used_amount, 0) / NULLIF(COALESCE(a.total_credit_limit, 0), 0) AS overall_limit_utilization_rate,
    COALESCE(a.total_card_count, 0)    AS total_card_count,
    COALESCE(a.total_credit_limit, 0) / NULLIF(COALESCE(a.total_card_count, 0), 0)  AS avg_limit_per_card,

    -- ===== By Institution: utilization rate =====
    a.nubank_limit_utilization_rate,
    a.mercadopago_limit_utilization_rate,
    a.bb_limit_utilization_rate,
    a.itau_limit_utilization_rate,
    a.santander_limit_utilization_rate,
    a.picpay_limit_utilization_rate,
    a.caixa_limit_utilization_rate,
    a.bradesco_limit_utilization_rate,
    a.outros_limit_utilization_rate,

    -- ===== By Institution: total credit limit =====
    COALESCE(a.nubank_total_credit_limit, 0)      AS nubank_total_credit_limit,
    COALESCE(a.mercadopago_total_credit_limit, 0)  AS mercadopago_total_credit_limit,
    COALESCE(a.bb_total_credit_limit, 0)           AS bb_total_credit_limit,
    COALESCE(a.itau_total_credit_limit, 0)         AS itau_total_credit_limit,
    COALESCE(a.santander_total_credit_limit, 0)    AS santander_total_credit_limit,
    COALESCE(a.picpay_total_credit_limit, 0)       AS picpay_total_credit_limit,
    COALESCE(a.caixa_total_credit_limit, 0)        AS caixa_total_credit_limit,
    COALESCE(a.bradesco_total_credit_limit, 0)     AS bradesco_total_credit_limit,
    COALESCE(a.outros_total_credit_limit, 0)       AS outros_total_credit_limit,

    -- ===== By Institution: card count =====
    COALESCE(a.nubank_card_count, 0)      AS nubank_card_count,
    COALESCE(a.mercadopago_card_count, 0)  AS mercadopago_card_count,
    COALESCE(a.bb_card_count, 0)           AS bb_card_count,
    COALESCE(a.itau_card_count, 0)         AS itau_card_count,
    COALESCE(a.santander_card_count, 0)    AS santander_card_count,
    COALESCE(a.picpay_card_count, 0)       AS picpay_card_count,
    COALESCE(a.caixa_card_count, 0)        AS caixa_card_count,
    COALESCE(a.bradesco_card_count, 0)     AS bradesco_card_count,
    COALESCE(a.outros_card_count, 0)       AS outros_card_count,

    -- ===== By Institution: has card flag (derived from card count) =====
    CASE WHEN COALESCE(a.nubank_card_count, 0) > 0      THEN 1 ELSE 0 END AS nubank_has_institution_card_flag,
    CASE WHEN COALESCE(a.mercadopago_card_count, 0) > 0  THEN 1 ELSE 0 END AS mercadopago_has_institution_card_flag,
    CASE WHEN COALESCE(a.bb_card_count, 0) > 0           THEN 1 ELSE 0 END AS bb_has_institution_card_flag,
    CASE WHEN COALESCE(a.itau_card_count, 0) > 0         THEN 1 ELSE 0 END AS itau_has_institution_card_flag,
    CASE WHEN COALESCE(a.santander_card_count, 0) > 0    THEN 1 ELSE 0 END AS santander_has_institution_card_flag,
    CASE WHEN COALESCE(a.picpay_card_count, 0) > 0       THEN 1 ELSE 0 END AS picpay_has_institution_card_flag,
    CASE WHEN COALESCE(a.caixa_card_count, 0) > 0        THEN 1 ELSE 0 END AS caixa_has_institution_card_flag,
    CASE WHEN COALESCE(a.bradesco_card_count, 0) > 0     THEN 1 ELSE 0 END AS bradesco_has_institution_card_flag,
    CASE WHEN COALESCE(a.outros_card_count, 0) > 0       THEN 1 ELSE 0 END AS outros_has_institution_card_flag,

    -- ===== By Institution: flexible limit flag =====
    COALESCE(a.nubank_has_flexible_limit_card_flag, 0)      AS nubank_has_flexible_limit_card_flag,
    COALESCE(a.mercadopago_has_flexible_limit_card_flag, 0)  AS mercadopago_has_flexible_limit_card_flag,
    COALESCE(a.bb_has_flexible_limit_card_flag, 0)           AS bb_has_flexible_limit_card_flag,
    COALESCE(a.itau_has_flexible_limit_card_flag, 0)         AS itau_has_flexible_limit_card_flag,
    COALESCE(a.santander_has_flexible_limit_card_flag, 0)    AS santander_has_flexible_limit_card_flag,
    COALESCE(a.picpay_has_flexible_limit_card_flag, 0)       AS picpay_has_flexible_limit_card_flag,
    COALESCE(a.caixa_has_flexible_limit_card_flag, 0)        AS caixa_has_flexible_limit_card_flag,
    COALESCE(a.bradesco_has_flexible_limit_card_flag, 0)     AS bradesco_has_flexible_limit_card_flag,
    COALESCE(a.outros_has_flexible_limit_card_flag, 0)       AS outros_has_flexible_limit_card_flag,

    -- ===== By Tier: utilization rate =====
    COALESCE(a.black_tier_used_amount, 0)    / NULLIF(COALESCE(a.black_tier_total_limit, 0), 0)    AS black_tier_card_limit_utilization_rate,
    COALESCE(a.platinum_tier_used_amount, 0) / NULLIF(COALESCE(a.platinum_tier_total_limit, 0), 0) AS platinum_tier_card_limit_utilization_rate,
    COALESCE(a.gold_tier_used_amount, 0)     / NULLIF(COALESCE(a.gold_tier_total_limit, 0), 0)     AS gold_tier_card_limit_utilization_rate,
    COALESCE(a.standard_tier_used_amount, 0) / NULLIF(COALESCE(a.standard_tier_total_limit, 0), 0) AS standard_tier_card_limit_utilization_rate,
    COALESCE(a.debit_tier_used_amount, 0)    / NULLIF(COALESCE(a.debit_tier_total_limit, 0), 0)    AS debit_tier_card_limit_utilization_rate,
    COALESCE(a.business_tier_used_amount, 0) / NULLIF(COALESCE(a.business_tier_total_limit, 0), 0) AS business_tier_card_limit_utilization_rate,
    COALESCE(a.others_tier_used_amount, 0)   / NULLIF(COALESCE(a.others_tier_total_limit, 0), 0)   AS others_tier_card_limit_utilization_rate,

    -- ===== By Tier: total limit =====
    COALESCE(a.black_tier_total_limit, 0)    AS black_tier_card_total_limit,
    COALESCE(a.platinum_tier_total_limit, 0) AS platinum_tier_card_total_limit,
    COALESCE(a.gold_tier_total_limit, 0)     AS gold_tier_card_total_limit,
    COALESCE(a.standard_tier_total_limit, 0) AS standard_tier_card_total_limit,
    COALESCE(a.debit_tier_total_limit, 0)    AS debit_tier_card_total_limit,
    COALESCE(a.business_tier_total_limit, 0) AS business_tier_card_total_limit,
    COALESCE(a.others_tier_total_limit, 0)   AS others_tier_card_total_limit,

    -- ===== By Tier: card count =====
    COALESCE(a.black_tier_card_count, 0)    AS black_tier_card_count,
    COALESCE(a.platinum_tier_card_count, 0) AS platinum_tier_card_count,
    COALESCE(a.gold_tier_card_count, 0)     AS gold_tier_card_count,
    COALESCE(a.standard_tier_card_count, 0) AS standard_tier_card_count,
    COALESCE(a.debit_tier_card_count, 0)    AS debit_tier_card_count,
    COALESCE(a.business_tier_card_count, 0) AS business_tier_card_count,
    COALESCE(a.others_tier_card_count, 0)   AS others_tier_card_count,

    -- ===== Cross Institution x Tier: utilization rate =====
    a.nubank_black_institution_tier_limit_utilization_rate,
    a.nubank_platinum_institution_tier_limit_utilization_rate,
    a.nubank_gold_institution_tier_limit_utilization_rate,
    a.nubank_standard_institution_tier_limit_utilization_rate,
    a.nubank_debit_institution_tier_limit_utilization_rate,
    a.nubank_business_institution_tier_limit_utilization_rate,
    a.nubank_others_institution_tier_limit_utilization_rate,
    a.mercadopago_black_institution_tier_limit_utilization_rate,
    a.mercadopago_platinum_institution_tier_limit_utilization_rate,
    a.mercadopago_gold_institution_tier_limit_utilization_rate,
    a.mercadopago_standard_institution_tier_limit_utilization_rate,
    a.mercadopago_debit_institution_tier_limit_utilization_rate,
    a.mercadopago_business_institution_tier_limit_utilization_rate,
    a.mercadopago_others_institution_tier_limit_utilization_rate,
    a.bb_black_institution_tier_limit_utilization_rate,
    a.bb_platinum_institution_tier_limit_utilization_rate,
    a.bb_gold_institution_tier_limit_utilization_rate,
    a.bb_standard_institution_tier_limit_utilization_rate,
    a.bb_debit_institution_tier_limit_utilization_rate,
    a.bb_business_institution_tier_limit_utilization_rate,
    a.bb_others_institution_tier_limit_utilization_rate,
    a.itau_black_institution_tier_limit_utilization_rate,
    a.itau_platinum_institution_tier_limit_utilization_rate,
    a.itau_gold_institution_tier_limit_utilization_rate,
    a.itau_standard_institution_tier_limit_utilization_rate,
    a.itau_debit_institution_tier_limit_utilization_rate,
    a.itau_business_institution_tier_limit_utilization_rate,
    a.itau_others_institution_tier_limit_utilization_rate,
    a.santander_black_institution_tier_limit_utilization_rate,
    a.santander_platinum_institution_tier_limit_utilization_rate,
    a.santander_gold_institution_tier_limit_utilization_rate,
    a.santander_standard_institution_tier_limit_utilization_rate,
    a.santander_debit_institution_tier_limit_utilization_rate,
    a.santander_business_institution_tier_limit_utilization_rate,
    a.santander_others_institution_tier_limit_utilization_rate,
    a.picpay_black_institution_tier_limit_utilization_rate,
    a.picpay_platinum_institution_tier_limit_utilization_rate,
    a.picpay_gold_institution_tier_limit_utilization_rate,
    a.picpay_standard_institution_tier_limit_utilization_rate,
    a.picpay_debit_institution_tier_limit_utilization_rate,
    a.picpay_business_institution_tier_limit_utilization_rate,
    a.picpay_others_institution_tier_limit_utilization_rate,
    a.caixa_black_institution_tier_limit_utilization_rate,
    a.caixa_platinum_institution_tier_limit_utilization_rate,
    a.caixa_gold_institution_tier_limit_utilization_rate,
    a.caixa_standard_institution_tier_limit_utilization_rate,
    a.caixa_debit_institution_tier_limit_utilization_rate,
    a.caixa_business_institution_tier_limit_utilization_rate,
    a.caixa_others_institution_tier_limit_utilization_rate,
    a.bradesco_black_institution_tier_limit_utilization_rate,
    a.bradesco_platinum_institution_tier_limit_utilization_rate,
    a.bradesco_gold_institution_tier_limit_utilization_rate,
    a.bradesco_standard_institution_tier_limit_utilization_rate,
    a.bradesco_debit_institution_tier_limit_utilization_rate,
    a.bradesco_business_institution_tier_limit_utilization_rate,
    a.bradesco_others_institution_tier_limit_utilization_rate,
    a.outros_black_institution_tier_limit_utilization_rate,
    a.outros_platinum_institution_tier_limit_utilization_rate,
    a.outros_gold_institution_tier_limit_utilization_rate,
    a.outros_standard_institution_tier_limit_utilization_rate,
    a.outros_debit_institution_tier_limit_utilization_rate,
    a.outros_business_institution_tier_limit_utilization_rate,
    a.outros_others_institution_tier_limit_utilization_rate,

    -- ===== Cross Institution x Tier: has card flag =====
    COALESCE(a.nubank_black_has_institution_tier_card_flag, 0) AS nubank_black_has_institution_tier_card_flag,
    COALESCE(a.nubank_platinum_has_institution_tier_card_flag, 0) AS nubank_platinum_has_institution_tier_card_flag,
    COALESCE(a.nubank_gold_has_institution_tier_card_flag, 0) AS nubank_gold_has_institution_tier_card_flag,
    COALESCE(a.nubank_standard_has_institution_tier_card_flag, 0) AS nubank_standard_has_institution_tier_card_flag,
    COALESCE(a.nubank_debit_has_institution_tier_card_flag, 0) AS nubank_debit_has_institution_tier_card_flag,
    COALESCE(a.nubank_business_has_institution_tier_card_flag, 0) AS nubank_business_has_institution_tier_card_flag,
    COALESCE(a.nubank_others_has_institution_tier_card_flag, 0) AS nubank_others_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_black_has_institution_tier_card_flag, 0) AS mercadopago_black_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_platinum_has_institution_tier_card_flag, 0) AS mercadopago_platinum_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_gold_has_institution_tier_card_flag, 0) AS mercadopago_gold_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_standard_has_institution_tier_card_flag, 0) AS mercadopago_standard_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_debit_has_institution_tier_card_flag, 0) AS mercadopago_debit_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_business_has_institution_tier_card_flag, 0) AS mercadopago_business_has_institution_tier_card_flag,
    COALESCE(a.mercadopago_others_has_institution_tier_card_flag, 0) AS mercadopago_others_has_institution_tier_card_flag,
    COALESCE(a.bb_black_has_institution_tier_card_flag, 0) AS bb_black_has_institution_tier_card_flag,
    COALESCE(a.bb_platinum_has_institution_tier_card_flag, 0) AS bb_platinum_has_institution_tier_card_flag,
    COALESCE(a.bb_gold_has_institution_tier_card_flag, 0) AS bb_gold_has_institution_tier_card_flag,
    COALESCE(a.bb_standard_has_institution_tier_card_flag, 0) AS bb_standard_has_institution_tier_card_flag,
    COALESCE(a.bb_debit_has_institution_tier_card_flag, 0) AS bb_debit_has_institution_tier_card_flag,
    COALESCE(a.bb_business_has_institution_tier_card_flag, 0) AS bb_business_has_institution_tier_card_flag,
    COALESCE(a.bb_others_has_institution_tier_card_flag, 0) AS bb_others_has_institution_tier_card_flag,
    COALESCE(a.itau_black_has_institution_tier_card_flag, 0) AS itau_black_has_institution_tier_card_flag,
    COALESCE(a.itau_platinum_has_institution_tier_card_flag, 0) AS itau_platinum_has_institution_tier_card_flag,
    COALESCE(a.itau_gold_has_institution_tier_card_flag, 0) AS itau_gold_has_institution_tier_card_flag,
    COALESCE(a.itau_standard_has_institution_tier_card_flag, 0) AS itau_standard_has_institution_tier_card_flag,
    COALESCE(a.itau_debit_has_institution_tier_card_flag, 0) AS itau_debit_has_institution_tier_card_flag,
    COALESCE(a.itau_business_has_institution_tier_card_flag, 0) AS itau_business_has_institution_tier_card_flag,
    COALESCE(a.itau_others_has_institution_tier_card_flag, 0) AS itau_others_has_institution_tier_card_flag,
    COALESCE(a.santander_black_has_institution_tier_card_flag, 0) AS santander_black_has_institution_tier_card_flag,
    COALESCE(a.santander_platinum_has_institution_tier_card_flag, 0) AS santander_platinum_has_institution_tier_card_flag,
    COALESCE(a.santander_gold_has_institution_tier_card_flag, 0) AS santander_gold_has_institution_tier_card_flag,
    COALESCE(a.santander_standard_has_institution_tier_card_flag, 0) AS santander_standard_has_institution_tier_card_flag,
    COALESCE(a.santander_debit_has_institution_tier_card_flag, 0) AS santander_debit_has_institution_tier_card_flag,
    COALESCE(a.santander_business_has_institution_tier_card_flag, 0) AS santander_business_has_institution_tier_card_flag,
    COALESCE(a.santander_others_has_institution_tier_card_flag, 0) AS santander_others_has_institution_tier_card_flag,
    COALESCE(a.picpay_black_has_institution_tier_card_flag, 0) AS picpay_black_has_institution_tier_card_flag,
    COALESCE(a.picpay_platinum_has_institution_tier_card_flag, 0) AS picpay_platinum_has_institution_tier_card_flag,
    COALESCE(a.picpay_gold_has_institution_tier_card_flag, 0) AS picpay_gold_has_institution_tier_card_flag,
    COALESCE(a.picpay_standard_has_institution_tier_card_flag, 0) AS picpay_standard_has_institution_tier_card_flag,
    COALESCE(a.picpay_debit_has_institution_tier_card_flag, 0) AS picpay_debit_has_institution_tier_card_flag,
    COALESCE(a.picpay_business_has_institution_tier_card_flag, 0) AS picpay_business_has_institution_tier_card_flag,
    COALESCE(a.picpay_others_has_institution_tier_card_flag, 0) AS picpay_others_has_institution_tier_card_flag,
    COALESCE(a.caixa_black_has_institution_tier_card_flag, 0) AS caixa_black_has_institution_tier_card_flag,
    COALESCE(a.caixa_platinum_has_institution_tier_card_flag, 0) AS caixa_platinum_has_institution_tier_card_flag,
    COALESCE(a.caixa_gold_has_institution_tier_card_flag, 0) AS caixa_gold_has_institution_tier_card_flag,
    COALESCE(a.caixa_standard_has_institution_tier_card_flag, 0) AS caixa_standard_has_institution_tier_card_flag,
    COALESCE(a.caixa_debit_has_institution_tier_card_flag, 0) AS caixa_debit_has_institution_tier_card_flag,
    COALESCE(a.caixa_business_has_institution_tier_card_flag, 0) AS caixa_business_has_institution_tier_card_flag,
    COALESCE(a.caixa_others_has_institution_tier_card_flag, 0) AS caixa_others_has_institution_tier_card_flag,
    COALESCE(a.bradesco_black_has_institution_tier_card_flag, 0) AS bradesco_black_has_institution_tier_card_flag,
    COALESCE(a.bradesco_platinum_has_institution_tier_card_flag, 0) AS bradesco_platinum_has_institution_tier_card_flag,
    COALESCE(a.bradesco_gold_has_institution_tier_card_flag, 0) AS bradesco_gold_has_institution_tier_card_flag,
    COALESCE(a.bradesco_standard_has_institution_tier_card_flag, 0) AS bradesco_standard_has_institution_tier_card_flag,
    COALESCE(a.bradesco_debit_has_institution_tier_card_flag, 0) AS bradesco_debit_has_institution_tier_card_flag,
    COALESCE(a.bradesco_business_has_institution_tier_card_flag, 0) AS bradesco_business_has_institution_tier_card_flag,
    COALESCE(a.bradesco_others_has_institution_tier_card_flag, 0) AS bradesco_others_has_institution_tier_card_flag,
    COALESCE(a.outros_black_has_institution_tier_card_flag, 0) AS outros_black_has_institution_tier_card_flag,
    COALESCE(a.outros_platinum_has_institution_tier_card_flag, 0) AS outros_platinum_has_institution_tier_card_flag,
    COALESCE(a.outros_gold_has_institution_tier_card_flag, 0) AS outros_gold_has_institution_tier_card_flag,
    COALESCE(a.outros_standard_has_institution_tier_card_flag, 0) AS outros_standard_has_institution_tier_card_flag,
    COALESCE(a.outros_debit_has_institution_tier_card_flag, 0) AS outros_debit_has_institution_tier_card_flag,
    COALESCE(a.outros_business_has_institution_tier_card_flag, 0) AS outros_business_has_institution_tier_card_flag,
    COALESCE(a.outros_others_has_institution_tier_card_flag, 0) AS outros_others_has_institution_tier_card_flag

FROM user_keys k
LEFT JOIN all_agg a
    ON k.shopee_user_id = a.shopee_user_id
;
