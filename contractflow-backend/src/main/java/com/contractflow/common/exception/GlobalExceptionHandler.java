package com.contractflow.common.exception;

import com.contractflow.common.response.ApiResponse;
import com.contractflow.common.util.TraceIds;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(
            BusinessException exception,
            HttpServletRequest request
    ) {
        ErrorCode code = exception.errorCode();
        return ResponseEntity
                .status(code.status())
                .body(ApiResponse.failure(code.name(), exception.getMessage(), request.getRequestURI(), TraceIds.current()));
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, ConstraintViolationException.class})
    public ResponseEntity<ApiResponse<Void>> handleValidationException(Exception exception, HttpServletRequest request) {
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.failure(
                        ErrorCode.VALIDATION_ERROR.name(),
                        exception.getMessage(),
                        request.getRequestURI(),
                        TraceIds.current()
                ));
    }

    @ExceptionHandler(OptimisticLockingFailureException.class)
    public ResponseEntity<ApiResponse<Void>> handleVersionConflict(
            OptimisticLockingFailureException exception,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(
                        ErrorCode.VERSION_CONFLICT.name(),
                        "Resource was modified by another request",
                        request.getRequestURI(),
                        TraceIds.current()
                ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleUnexpectedException(Exception exception, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.failure(
                        ErrorCode.INTERNAL_SERVER_ERROR.name(),
                        "Unexpected server error",
                        request.getRequestURI(),
                        TraceIds.current()
                ));
    }
}

