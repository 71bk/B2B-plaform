INSERT INTO roles (code, name, description)
VALUES
    ('OWNER', 'Owner', 'Organization owner'),
    ('SALES', 'Sales', 'Sales user'),
    ('ADMIN', 'Admin', 'Back office reviewer'),
    ('FINANCE', 'Finance', 'Finance reviewer'),
    ('MANAGER', 'Manager', 'Manager approver'),
    ('SYSTEM_ADMIN', 'System Admin', 'Platform administrator')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE organizations (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    billing_email VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organization_members (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    role_id BIGINT NOT NULL REFERENCES roles(id),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    invited_by BIGINT REFERENCES users(id),
    joined_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ux_organization_members_org_user UNIQUE (organization_id, user_id)
);

CREATE TABLE organization_invitations (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id),
    email VARCHAR(255) NOT NULL,
    role_id BIGINT NOT NULL REFERENCES roles(id),
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMP NOT NULL,
    invited_by BIGINT NOT NULL REFERENCES users(id),
    accepted_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP
);

CREATE TABLE subscription_plans (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    monthly_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    max_members INTEGER NOT NULL DEFAULT 5,
    max_storage_mb INTEGER NOT NULL DEFAULT 1024,
    features JSONB NOT NULL DEFAULT '{}'::jsonb,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE organization_subscriptions (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id),
    plan_id BIGINT NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(20) NOT NULL DEFAULT 'TRIALING',
    trial_ends_at TIMESTAMP,
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO subscription_plans (code, name, monthly_price, max_members, max_storage_mb, features, status)
VALUES ('FREE', 'Free', 0, 5, 1024, '{"ai": false, "dashboard": true}'::jsonb, 'ACTIVE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO organizations (name, slug, status, billing_email)
VALUES ('Default Organization', 'default', 'ACTIVE', 'admin@contractflow.local');

INSERT INTO organization_subscriptions (organization_id, plan_id, status, trial_ends_at, current_period_start, current_period_end)
SELECT org.id, plan.id, 'TRIALING', CURRENT_TIMESTAMP + INTERVAL '14 days', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 month'
FROM organizations org
CROSS JOIN subscription_plans plan
WHERE org.slug = 'default'
  AND plan.code = 'FREE';

INSERT INTO organization_members (organization_id, user_id, role_id, status, joined_at)
SELECT org.id,
       u.id,
       COALESCE(MIN(ur.role_id), owner_role.id),
       'ACTIVE',
       CURRENT_TIMESTAMP
FROM organizations org
CROSS JOIN users u
CROSS JOIN roles owner_role
LEFT JOIN user_roles ur ON ur.user_id = u.id
WHERE org.slug = 'default'
  AND owner_role.code = 'OWNER'
GROUP BY org.id, u.id, owner_role.id
ON CONFLICT (organization_id, user_id) DO NOTHING;

ALTER TABLE clients ADD COLUMN organization_id BIGINT;
UPDATE clients SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE clients ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE clients ADD CONSTRAINT fk_clients_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE projects ADD COLUMN organization_id BIGINT;
UPDATE projects SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE projects ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE projects ADD CONSTRAINT fk_projects_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE files ADD COLUMN organization_id BIGINT;
UPDATE files SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE files ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE files ADD CONSTRAINT fk_files_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE contracts ADD COLUMN organization_id BIGINT;
UPDATE contracts SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE contracts ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE contracts ADD CONSTRAINT fk_contracts_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE refund_cases ADD COLUMN organization_id BIGINT;
UPDATE refund_cases SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE refund_cases ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE refund_cases ADD CONSTRAINT fk_refund_cases_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE notifications ADD COLUMN organization_id BIGINT;
UPDATE notifications SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE notifications ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE operation_audit_logs ADD COLUMN organization_id BIGINT;
UPDATE operation_audit_logs SET organization_id = (SELECT id FROM organizations WHERE slug = 'default') WHERE organization_id IS NULL;
ALTER TABLE operation_audit_logs ADD CONSTRAINT fk_operation_audit_logs_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE clients DROP CONSTRAINT IF EXISTS clients_tax_id_key;
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_contract_no_key;
ALTER TABLE refund_cases DROP CONSTRAINT IF EXISTS refund_cases_case_no_key;

CREATE UNIQUE INDEX ux_clients_org_tax_id ON clients(organization_id, tax_id) WHERE tax_id IS NOT NULL;
CREATE UNIQUE INDEX ux_contracts_org_contract_no ON contracts(organization_id, contract_no);
CREATE UNIQUE INDEX ux_refund_cases_org_case_no ON refund_cases(organization_id, case_no);
CREATE UNIQUE INDEX ux_organization_subscriptions_current
    ON organization_subscriptions(organization_id)
    WHERE status IN ('TRIALING', 'ACTIVE', 'PAST_DUE');

CREATE UNIQUE INDEX ux_clients_id_org ON clients(id, organization_id);
CREATE UNIQUE INDEX ux_projects_id_org ON projects(id, organization_id);
CREATE UNIQUE INDEX ux_files_id_org ON files(id, organization_id);

ALTER TABLE projects
    ADD CONSTRAINT fk_projects_client_same_org
    FOREIGN KEY (client_id, organization_id) REFERENCES clients(id, organization_id);

ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_project_same_org
    FOREIGN KEY (project_id, organization_id) REFERENCES projects(id, organization_id);

ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_file_same_org
    FOREIGN KEY (file_id, organization_id) REFERENCES files(id, organization_id);

ALTER TABLE refund_cases
    ADD CONSTRAINT fk_refund_cases_client_same_org
    FOREIGN KEY (client_id, organization_id) REFERENCES clients(id, organization_id);

ALTER TABLE refund_cases
    ADD CONSTRAINT fk_refund_cases_project_same_org
    FOREIGN KEY (project_id, organization_id) REFERENCES projects(id, organization_id);

CREATE INDEX idx_organization_members_org_user ON organization_members(organization_id, user_id);
CREATE INDEX idx_organization_invitations_org_email ON organization_invitations(organization_id, email);
CREATE INDEX idx_organization_subscriptions_org ON organization_subscriptions(organization_id);

CREATE INDEX idx_clients_organization_id ON clients(organization_id);
CREATE INDEX idx_projects_organization_id ON projects(organization_id);
CREATE INDEX idx_contracts_organization_id ON contracts(organization_id);
CREATE INDEX idx_files_organization_id ON files(organization_id);
CREATE INDEX idx_refund_cases_org_status ON refund_cases(organization_id, status);
CREATE INDEX idx_refund_cases_org_applicant_id ON refund_cases(organization_id, applicant_id);
CREATE INDEX idx_refund_cases_org_assignee_id ON refund_cases(organization_id, current_assignee_id);
CREATE INDEX idx_refund_cases_org_created_at ON refund_cases(organization_id, created_at);
CREATE INDEX idx_notifications_org_recipient_read ON notifications(organization_id, recipient_id, read_at);
CREATE INDEX idx_operation_audit_logs_org_resource ON operation_audit_logs(organization_id, resource_type, resource_id);
