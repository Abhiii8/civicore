<?php
/**
 * CiviCore - JWT Configuration
 * 
 * JWT token generation and validation
 * Ensures secure authentication for all API endpoints
 */

class JWT {
    private $secret_key = "civicore_secret_key_2024_governance_system";
    private $algorithm = "HS256";
    private $expiration = 86400; // 24 hours

    /**
     * Generate JWT token
     * @param array $payload User data to encode
     * @return string JWT token
     */
    public function generateToken($payload) {
        $header = json_encode([
            "typ" => "JWT",
            "alg" => $this->algorithm
        ]);

        $payload['iat'] = time();
        $payload['exp'] = time() + $this->expiration;
        $payload = json_encode($payload);

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, $this->secret_key, true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    /**
     * Validate JWT token
     * @param string $token JWT token
     * @return array|false Decoded payload or false if invalid
     */
    public function validateToken($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        list($base64UrlHeader, $base64UrlPayload, $base64UrlSignature) = $parts;

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, $this->secret_key, true);
        $base64UrlSignatureCheck = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        if ($base64UrlSignature !== $base64UrlSignatureCheck) {
            return false;
        }

        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $base64UrlPayload)), true);

        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        return $payload;
    }
}
