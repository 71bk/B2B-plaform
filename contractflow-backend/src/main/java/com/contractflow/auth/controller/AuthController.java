package com.contractflow.auth.controller;

import com.contractflow.auth.dto.LoginRequest;
import com.contractflow.auth.dto.MeResponse;
import com.contractflow.common.response.ApiResponse;
import com.contractflow.common.util.TraceIds;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @PostMapping("/login")
    public ApiResponse<Map<String, String>> login(@Valid @RequestBody LoginRequest request, HttpServletRequest servletRequest) {
        return ApiResponse.success(
                Map.of("status", "auth service skeleton ready"),
                servletRequest.getRequestURI(),
                TraceIds.current()
        );
    }

    @PostMapping("/logout")
    public ApiResponse<Map<String, String>> logout(HttpServletRequest request) {
        return ApiResponse.success(Map.of("status", "logout skeleton ready"), request.getRequestURI(), TraceIds.current());
    }

    @PostMapping("/refresh")
    public ApiResponse<Map<String, String>> refresh(HttpServletRequest request) {
        return ApiResponse.success(Map.of("status", "refresh skeleton ready"), request.getRequestURI(), TraceIds.current());
    }

    @GetMapping("/csrf")
    public ApiResponse<Map<String, String>> csrf(HttpServletRequest request, CsrfToken csrfToken) {
        return ApiResponse.success(
                Map.of("headerName", csrfToken.getHeaderName(), "token", csrfToken.getToken()),
                request.getRequestURI(),
                TraceIds.current()
        );
    }

    @GetMapping("/me")
    public ApiResponse<MeResponse> me(HttpServletRequest request) {
        MeResponse response = new MeResponse(null, null, null, List.of());
        return ApiResponse.success(response, request.getRequestURI(), TraceIds.current());
    }
}
