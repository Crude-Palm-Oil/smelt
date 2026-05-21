CREATE TYPE public.lint_status AS ENUM (
    'NA',
    'NE',
    'pass',
    'info',
    'warn',
    'error',
    'fatal'
);


CREATE TYPE public.scan_status AS ENUM (
    'paused',
    'running',
    'stopped',
    'NA',
    'NE',
    'pass',
    'info',
    'warn',
    'error',
    'fatal'
);


CREATE TABLE public.certificates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fingerprint character varying(64) NOT NULL,
    common_name text,
    not_after timestamp with time zone NOT NULL,
    issuer_cn text,
    raw_pem text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    file_name text
);


CREATE TABLE public.lints (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scan_id uuid NOT NULL,
    target_id uuid,
    cert_id uuid,
    scanned_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status public.lint_status NOT NULL
);


CREATE TABLE public.reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scan_id uuid NOT NULL,
    status text DEFAULT 'Pending'::text NOT NULL,
    file_path text,
    file_size bigint,
    generated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_reports_status CHECK ((status = ANY (ARRAY['Pending'::text, 'Generating'::text, 'Ready'::text, 'Failed'::text])))
);


CREATE TABLE public.scans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recurring_id uuid,
    scanned_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    target_count integer DEFAULT 0 NOT NULL,
    name character varying DEFAULT 'New Scan'::character varying NOT NULL,
    status public.scan_status DEFAULT 'stopped'::public.scan_status NOT NULL,
    processed_count integer DEFAULT 0 NOT NULL
);

CREATE TABLE public.targets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ip_address text,
    hostname text,
    port integer NOT NULL,
    common_name text,
    issuer_cn text,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_targets_ip_or_dns CHECK (((ip_address IS NOT NULL) OR (hostname IS NOT NULL))),
    CONSTRAINT chk_targets_port_range CHECK (((port > 0) AND (port <= 65535)))
);

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    created_at time with time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at time with time zone,
    updated_at time with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.recurring_scans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    cron text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    domain text NOT NULL
);

ALTER TABLE ONLY public.configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_fingerprint_key UNIQUE (fingerprint);

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.lints
    ADD CONSTRAINT lints_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.recurring_scans
    ADD CONSTRAINT recurring_scans_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_scan_id_key UNIQUE (scan_id);


ALTER TABLE ONLY public.scans
    ADD CONSTRAINT scans_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


CREATE INDEX idx_reports_scan_id ON public.reports USING btree (scan_id);


CREATE INDEX idx_reports_status ON public.reports USING btree (status);

CREATE INDEX index_certificates ON public.certificates USING btree (id, fingerprint);

CREATE INDEX index_lints ON public.lints USING btree (id, scan_id);

CREATE INDEX index_scans ON public.scans USING btree (id);


CREATE INDEX index_targets ON public.targets USING btree (id);


ALTER TABLE ONLY public.lints
    ADD CONSTRAINT fk_lints_scans FOREIGN KEY (scan_id) REFERENCES public.scans(id) ON DELETE CASCADE;


ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_reports_scan FOREIGN KEY (scan_id) REFERENCES public.scans(id) ON DELETE CASCADE;


ALTER TABLE ONLY public.lints
    ADD CONSTRAINT fk_scans_target FOREIGN KEY (target_id) REFERENCES public.targets(id) ON DELETE CASCADE;

INSERT INTO public.users (
    name,
    email,
    password_hash
)
VALUES (
    'Test User',
    'test@email.com',
    '$2b$12$F12YofsyO5ukBevknYGzf.kVEt0I7sTtlPGSkVRjC4nrgCHPZInsS'
)
ON CONFLICT (email) DO UPDATE
SET
    name = EXCLUDED.name,
    password_hash = EXCLUDED.password_hash,
    updated_at = CURRENT_TIMESTAMP;
