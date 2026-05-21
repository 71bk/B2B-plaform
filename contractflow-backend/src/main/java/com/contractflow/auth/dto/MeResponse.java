package com.contractflow.auth.dto;

import java.util.List;

public record MeResponse(
        Long id,
        String email,
        String name,
        List<String> roles
) {
}

