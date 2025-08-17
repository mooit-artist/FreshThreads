#!/usr/bin/env python3
"""
Example Python unit tests for FreshThreads using pytest
"""

import pytest
from typing import Dict, Any
import json


def format_price(price: float) -> str:
    """Format price as currency string"""
    if not isinstance(price, (int, float)) or price < 0:
        raise ValueError("Price must be a non-negative number")
    return f"${price:.2f}"


def validate_product_data(product: Dict[str, Any]) -> bool:
    """Validate product data structure"""
    required_fields = ['id', 'name', 'price', 'category']

    if not isinstance(product, dict):
        return False

    for field in required_fields:
        if field not in product:
            return False

    if not isinstance(product['price'], (int, float)) or product['price'] < 0:
        return False

    return True


class TestFreshThreadsUtils:
    """Test suite for FreshThreads utility functions"""

    @pytest.mark.unit
    def test_format_price_valid_inputs(self):
        """Test price formatting with valid inputs"""
        assert format_price(19.99) == "$19.99"
        assert format_price(0) == "$0.00"
        assert format_price(100) == "$100.00"
        assert format_price(0.99) == "$0.99"

    @pytest.mark.unit
    def test_format_price_invalid_inputs(self):
        """Test price formatting with invalid inputs"""
        with pytest.raises(ValueError, match="Price must be a non-negative number"):
            format_price(-1)

        with pytest.raises(ValueError, match="Price must be a non-negative number"):
            format_price("19.99")

        with pytest.raises(ValueError, match="Price must be a non-negative number"):
            format_price(None)

    @pytest.mark.unit
    def test_validate_product_data_valid(self):
        """Test product data validation with valid data"""
        valid_product = {
            'id': 'tshirt-001',
            'name': 'Vintage Logo Tee',
            'price': 24.99,
            'category': 'apparel'
        }
        assert validate_product_data(valid_product) is True

    @pytest.mark.unit
    def test_validate_product_data_invalid(self):
        """Test product data validation with invalid data"""
        # Missing required fields
        invalid_product_1 = {
            'id': 'tshirt-001',
            'name': 'Vintage Logo Tee'
        }
        assert validate_product_data(invalid_product_1) is False

        # Invalid price
        invalid_product_2 = {
            'id': 'tshirt-001',
            'name': 'Vintage Logo Tee',
            'price': -10.0,
            'category': 'apparel'
        }
        assert validate_product_data(invalid_product_2) is False

        # Not a dictionary
        assert validate_product_data("not a dict") is False
        assert validate_product_data(None) is False


class TestFreshThreadsIntegration:
    """Integration tests for FreshThreads components"""

    @pytest.mark.integration
    def test_product_catalog_processing(self):
        """Test processing a catalog of products"""
        catalog = [
            {
                'id': 'tshirt-001',
                'name': 'Vintage Logo Tee',
                'price': 24.99,
                'category': 'apparel'
            },
            {
                'id': 'tshirt-002',
                'name': 'Modern Graphic Tee',
                'price': 29.99,
                'category': 'apparel'
            }
        ]

        valid_products = [p for p in catalog if validate_product_data(p)]
        assert len(valid_products) == 2

        formatted_prices = [format_price(p['price']) for p in valid_products]
        assert formatted_prices == ['$24.99', '$29.99']


@pytest.mark.slow
def test_large_catalog_processing():
    """Test processing a large product catalog"""
    large_catalog = []
    for i in range(1000):
        product = {
            'id': f'product-{i:04d}',
            'name': f'Product {i}',
            'price': float(i * 0.99),
            'category': 'test'
        }
        large_catalog.append(product)

    valid_products = [p for p in large_catalog if validate_product_data(p)]
    assert len(valid_products) == 1000

    # Test that all prices format correctly
    for product in valid_products[:10]:  # Test first 10
        formatted = format_price(product['price'])
        assert formatted.startswith('$')
        assert '.' in formatted
