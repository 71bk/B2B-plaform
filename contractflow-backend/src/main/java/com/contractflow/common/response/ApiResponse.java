package com.contractflow.common.response;

public record ApiResponse<T>(
        boolean success,
        String code,
        String message,
        T data,
        String path,
        String traceId
) {
    public static <T> ApiResponse<T> success(T data, String path, String traceId) {
        return new ApiResponse<>(true, "SUCCESS", "Request processed successfully", data, path, traceId);
    }

    public static <T> ApiResponse<T> failure(String code, String message, String path, String traceId) {
        return new ApiResponse<>(false, code, message, null, path, traceId);
    }
}

