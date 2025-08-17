package com.freshthreads.test;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import static org.junit.jupiter.api.Assertions.*;
import static org.assertj.core.api.Assertions.*;

/**
 * Example JUnit 5 tests for FreshThreads components
 */
@DisplayName("FreshThreads Core Tests")
public class FreshThreadsCoreTest {

    @Nested
    @DisplayName("Price Utilities")
    class PriceUtilitiesTest {

        @Test
        @DisplayName("Should format valid prices correctly")
        void shouldFormatValidPricesCorrectly() {
            // Given
            double price1 = 19.99;
            double price2 = 0.00;
            double price3 = 100.00;

            // When & Then
            assertEquals("$19.99", formatPrice(price1));
            assertEquals("$0.00", formatPrice(price2));
            assertEquals("$100.00", formatPrice(price3));
        }

        @Test
        @DisplayName("Should reject negative prices")
        void shouldRejectNegativePrices() {
            // Given
            double negativePrice = -10.50;

            // When & Then
            IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> formatPrice(negativePrice)
            );

            assertThat(exception.getMessage())
                .contains("Price must be non-negative");
        }

        private String formatPrice(double price) {
            if (price < 0) {
                throw new IllegalArgumentException("Price must be non-negative");
            }
            return String.format("$%.2f", price);
        }
    }

    @Nested
    @DisplayName("Product Validation")
    class ProductValidationTest {

        private Product validProduct;

        @BeforeEach
        void setUp() {
            validProduct = new Product("TSH001", "Vintage Logo Tee", 24.99, "Apparel");
        }

        @Test
        @DisplayName("Should validate complete product data")
        void shouldValidateCompleteProductData() {
            // When
            boolean isValid = validProduct.isValid();

            // Then
            assertTrue(isValid);
        }

        @Test
        @DisplayName("Should reject products with missing data")
        void shouldRejectProductsWithMissingData() {
            // Given
            Product incompleteProduct = new Product(null, "Vintage Tee", 24.99, "Apparel");

            // When
            boolean isValid = incompleteProduct.isValid();

            // Then
            assertFalse(isValid);
        }

        @Test
        @DisplayName("Should reject products with invalid prices")
        void shouldRejectProductsWithInvalidPrices() {
            // Given
            Product invalidPriceProduct = new Product("TSH002", "Vintage Tee", -10.00, "Apparel");

            // When
            boolean isValid = invalidPriceProduct.isValid();

            // Then
            assertFalse(isValid);
        }
    }

    // Simple Product class for testing
    static class Product {
        private final String id;
        private final String name;
        private final double price;
        private final String category;

        public Product(String id, String name, double price, String category) {
            this.id = id;
            this.name = name;
            this.price = price;
            this.category = category;
        }

        public boolean isValid() {
            return id != null && !id.trim().isEmpty() &&
                   name != null && !name.trim().isEmpty() &&
                   price >= 0 &&
                   category != null && !category.trim().isEmpty();
        }

        // Getters
        public String getId() { return id; }
        public String getName() { return name; }
        public double getPrice() { return price; }
        public String getCategory() { return category; }
    }
}
