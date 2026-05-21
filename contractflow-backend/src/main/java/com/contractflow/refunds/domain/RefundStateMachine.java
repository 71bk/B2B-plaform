package com.contractflow.refunds.domain;

import com.contractflow.common.exception.BusinessException;
import com.contractflow.common.exception.ErrorCode;

import java.util.List;

public class RefundStateMachine {

    private static final List<RefundTransition> TRANSITIONS = List.of(
            new RefundTransition(RefundStatus.DRAFT, RefundAction.SUBMIT, RefundStatus.ADMIN_REVIEW, RefundRole.SALES),
            new RefundTransition(RefundStatus.DRAFT, RefundAction.CANCEL, RefundStatus.CANCELLED, RefundRole.SALES),
            new RefundTransition(RefundStatus.ADMIN_REVIEW, RefundAction.ADMIN_APPROVE, RefundStatus.FINANCE_REVIEW, RefundRole.ADMIN),
            new RefundTransition(RefundStatus.ADMIN_REVIEW, RefundAction.RETURN, RefundStatus.DRAFT, RefundRole.ADMIN),
            new RefundTransition(RefundStatus.FINANCE_REVIEW, RefundAction.FINANCE_CONFIRM, RefundStatus.MANAGER_REVIEW, RefundRole.FINANCE),
            new RefundTransition(RefundStatus.FINANCE_REVIEW, RefundAction.RETURN, RefundStatus.DRAFT, RefundRole.FINANCE),
            new RefundTransition(RefundStatus.MANAGER_REVIEW, RefundAction.MANAGER_APPROVE, RefundStatus.APPROVED, RefundRole.MANAGER),
            new RefundTransition(RefundStatus.MANAGER_REVIEW, RefundAction.REJECT, RefundStatus.REJECTED, RefundRole.MANAGER),
            new RefundTransition(RefundStatus.APPROVED, RefundAction.MARK_PAID, RefundStatus.PAID, RefundRole.FINANCE)
    );

    public RefundStatus transit(RefundStatus currentStatus, RefundAction action, RefundRole role) {
        if (role == RefundRole.SYSTEM_ADMIN) {
            return findTransition(currentStatus, action).to();
        }

        return TRANSITIONS.stream()
                .filter(transition -> transition.from() == currentStatus)
                .filter(transition -> transition.action() == action)
                .filter(transition -> transition.role() == role)
                .findFirst()
                .map(RefundTransition::to)
                .orElseThrow(() -> invalidTransition(currentStatus, action, role));
    }

    private RefundTransition findTransition(RefundStatus currentStatus, RefundAction action) {
        return TRANSITIONS.stream()
                .filter(transition -> transition.from() == currentStatus)
                .filter(transition -> transition.action() == action)
                .findFirst()
                .orElseThrow(() -> invalidTransition(currentStatus, action, RefundRole.SYSTEM_ADMIN));
    }

    private BusinessException invalidTransition(RefundStatus currentStatus, RefundAction action, RefundRole role) {
        return new BusinessException(
                ErrorCode.REFUND_CASE_INVALID_TRANSITION,
                "Refund case cannot execute action %s from status %s by role %s".formatted(action, currentStatus, role)
        );
    }
}

