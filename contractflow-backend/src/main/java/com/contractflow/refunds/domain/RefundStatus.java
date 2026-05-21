package com.contractflow.refunds.domain;

public enum RefundStatus {
    DRAFT,
    ADMIN_REVIEW,
    FINANCE_REVIEW,
    MANAGER_REVIEW,
    APPROVED,
    REJECTED,
    PAID,
    CANCELLED;

    public boolean isTerminal() {
        return this == PAID || this == REJECTED || this == CANCELLED;
    }
}

