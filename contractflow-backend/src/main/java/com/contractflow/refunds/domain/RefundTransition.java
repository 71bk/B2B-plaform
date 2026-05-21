package com.contractflow.refunds.domain;

public record RefundTransition(
        RefundStatus from,
        RefundAction action,
        RefundStatus to,
        RefundRole role
) {
}

