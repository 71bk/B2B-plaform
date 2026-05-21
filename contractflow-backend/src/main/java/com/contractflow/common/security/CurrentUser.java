package com.contractflow.common.security;

import java.util.Set;

public record CurrentUser(
        Long id,
        String email,
        String name,
        Set<String> roles
) {
}

