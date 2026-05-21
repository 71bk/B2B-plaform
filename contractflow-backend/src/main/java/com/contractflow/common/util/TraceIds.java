package com.contractflow.common.util;

import org.slf4j.MDC;

import java.util.UUID;

public final class TraceIds {

    public static final String MDC_KEY = "traceId";
    public static final String HEADER = "X-Trace-Id";

    private TraceIds() {
    }

    public static String current() {
        String traceId = MDC.get(MDC_KEY);
        if (traceId == null || traceId.isBlank()) {
            traceId = UUID.randomUUID().toString();
            MDC.put(MDC_KEY, traceId);
        }
        return traceId;
    }
}

