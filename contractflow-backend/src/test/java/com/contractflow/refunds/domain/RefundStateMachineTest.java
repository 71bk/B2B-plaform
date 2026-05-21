package com.contractflow.refunds.domain;

import com.contractflow.common.exception.BusinessException;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RefundStateMachineTest {

    private final RefundStateMachine stateMachine = new RefundStateMachine();

    @Test
    void salesCanSubmitDraftToAdminReview() {
        RefundStatus next = stateMachine.transit(RefundStatus.DRAFT, RefundAction.SUBMIT, RefundRole.SALES);

        assertThat(next).isEqualTo(RefundStatus.ADMIN_REVIEW);
    }

    @Test
    void salesCannotApproveAdminReviewCase() {
        assertThatThrownBy(() -> stateMachine.transit(
                RefundStatus.ADMIN_REVIEW,
                RefundAction.ADMIN_APPROVE,
                RefundRole.SALES
        )).isInstanceOf(BusinessException.class);
    }

    @Test
    void paidIsTerminal() {
        assertThat(RefundStatus.PAID.isTerminal()).isTrue();
    }
}

