// Product Templates for Print-on-Demand Integration
// This file contains templates and mappings for different POD providers

class PODProductTemplates {
  constructor() {
    this.templates = {
      printify: this.getPrintifyTemplates(),
      printful: this.getPrintfulTemplates(),
    };
  }

  getPrintifyTemplates() {
    return {
      // Gildan 18000 Unisex Heavy Blend Sweatshirt
      tshirt_basic: {
        blueprint_id: 5, // Basic T-shirt blueprint
        print_provider_id: 5, // Printify provider (e.g., Gooten)
        variants: [
          {
            id: 1, // Variant ID for size S
            price: 2499, // Price in cents
            is_enabled: true,
          },
        ],
        print_areas: [
          {
            variant_ids: [1],
            placeholders: [
              {
                position: 'front',
                images: [
                  {
                    id: 'image_id', // This will be replaced with actual image ID
                    x: 0.5,
                    y: 0.5,
                    scale: 1,
                    angle: 0,
                  },
                ],
              },
            ],
          },
        ],
      },

      tshirt_longsleeve: {
        blueprint_id: 6, // Long sleeve T-shirt blueprint
        print_provider_id: 5,
        variants: [
          {
            id: 1,
            price: 3499, // Price in cents
            is_enabled: true,
          },
        ],
        print_areas: [
          {
            variant_ids: [1],
            placeholders: [
              {
                position: 'front',
                images: [
                  {
                    id: 'image_id',
                    x: 0.5,
                    y: 0.5,
                    scale: 1,
                    angle: 0,
                  },
                ],
              },
            ],
          },
        ],
      },
    };
  }

  getPrintfulTemplates() {
    return {
      tshirt_basic: {
        sync_product: {
          name: '', // Will be filled dynamically
          thumbnail: '', // Will be filled dynamically
          is_ignored: false,
        },
        sync_variants: [
          {
            retail_price: '24.99',
            variant_id: 4011, // Bella + Canvas 3001 Unisex Short Sleeve - S / Black
            files: [
              {
                type: 'front',
                url: '', // Will be filled dynamically
              },
            ],
          },
        ],
      },

      tshirt_longsleeve: {
        sync_product: {
          name: '',
          thumbnail: '',
          is_ignored: false,
        },
        sync_variants: [
          {
            retail_price: '34.99',
            variant_id: 4016, // Example long sleeve variant ID
            files: [
              {
                type: 'front',
                url: '',
              },
            ],
          },
        ],
      },
    };
  }

  // Get template based on product category and provider
  getTemplate(provider, category) {
    const providerTemplates = this.templates[provider];
    if (!providerTemplates) {
      throw new Error(`Unsupported provider: ${provider}`);
    }

    // Map categories to template keys
    const categoryMap = {
      't-shirts': 'tshirt_basic',
      'long-sleeve': 'tshirt_longsleeve',
    };

    const templateKey = categoryMap[category];
    if (!templateKey) {
      throw new Error(`Unsupported category for ${provider}: ${category}`);
    }

    return JSON.parse(JSON.stringify(providerTemplates[templateKey])); // Deep copy
  }

  // Create product data for specific provider
  createProductData(localProduct, provider, designImageUrl = null) {
    const template = this.getTemplate(provider, localProduct.category);

    if (provider === 'printify') {
      return this.fillPrintifyTemplate(template, localProduct, designImageUrl);
    } else if (provider === 'printful') {
      return this.fillPrintfulTemplate(template, localProduct, designImageUrl);
    }

    throw new Error(`Unsupported provider: ${provider}`);
  }

  fillPrintifyTemplate(template, localProduct, designImageUrl) {
    return {
      title: localProduct.name,
      description: localProduct.description,
      blueprint_id: template.blueprint_id,
      print_provider_id: template.print_provider_id,
      variants: template.variants.map((variant) => ({
        ...variant,
        price: Math.round(localProduct.basePrice * 100), // Convert to cents
      })),
      print_areas: designImageUrl
        ? template.print_areas.map((area) => ({
          ...area,
          placeholders: area.placeholders.map((placeholder) => ({
            ...placeholder,
            images: placeholder.images.map((image) => ({
              ...image,
              id: designImageUrl, // This would need to be uploaded first
            })),
          })),
        }))
        : template.print_areas,
    };
  }

  fillPrintfulTemplate(template, localProduct, designImageUrl) {
    return {
      sync_product: {
        ...template.sync_product,
        name: localProduct.name,
        thumbnail: designImageUrl || localProduct.images?.primary,
      },
      sync_variants: template.sync_variants.map((variant) => ({
        ...variant,
        retail_price: localProduct.basePrice.toString(),
        files: designImageUrl
          ? variant.files.map((file) => ({
            ...file,
            url: designImageUrl,
          }))
          : variant.files,
      })),
    };
  }

  // Get available product blueprints/variants for each provider
  static getAvailableProducts() {
    return {
      printify: {
        blueprints: {
          5: 'Unisex T-shirt',
          6: 'Unisex Long Sleeve T-shirt',
          7: "Women's T-shirt",
          8: "Men's T-shirt",
        },
        providers: {
          1: 'Printify Express',
          2: 'Printify Express US',
          3: 'Printify Express EU',
          5: 'Gooten',
          8: 'Monster Digital',
          25: 'Awkward Styles',
        },
      },
      printful: {
        products: {
          71: 'Bella + Canvas 3001 Unisex Short Sleeve T-Shirt',
          17: 'Gildan 18000 Unisex Heavy Blend Sweatshirt',
          146: 'Bella + Canvas 3501 Unisex Long Sleeve T-Shirt',
          181: "Bella + Canvas 6004 Women's The Favorite Tee",
        },
      },
    };
  }

  // Validate that a product can be created with given provider
  validateProductForProvider(localProduct, provider) {
    const errors = [];

    if (!localProduct.name || localProduct.name.trim() === '') {
      errors.push('Product name is required');
    }

    if (!localProduct.description || localProduct.description.trim() === '') {
      errors.push('Product description is required');
    }

    if (!localProduct.basePrice || localProduct.basePrice <= 0) {
      errors.push('Valid base price is required');
    }

    if (!['t-shirts', 'long-sleeve'].includes(localProduct.category)) {
      errors.push(
        `Category '${localProduct.category}' is not supported for ${provider}`,
      );
    }

    // Provider-specific validations
    if (provider === 'printify') {
      if (localProduct.name.length > 100) {
        errors.push('Printify product name cannot exceed 100 characters');
      }
    } else if (provider === 'printful') {
      if (localProduct.name.length > 70) {
        errors.push('Printful product name cannot exceed 70 characters');
      }
    }

    return {
      isValid: errors.length === 0,
      errors: errors,
    };
  }
}

// Color and size mappings for different providers
class PODVariantMappings {
  static getPrintifyColors() {
    return {
      Black: '#000000',
      White: '#FFFFFF',
      Navy: '#1B2951',
      'Heather Gray': '#9B9B9B',
      Red: '#FF0000',
      'Royal Blue': '#4169E1',
    };
  }

  static getPrintfulColors() {
    return {
      Black: '#000000',
      White: '#FFFFFF',
      Navy: '#1B2951',
      'Heather Grey': '#9B9B9B',
      Red: '#FF0000',
      Royal: '#4169E1',
    };
  }

  static getSizeMappings() {
    return {
      XS: 'XS',
      S: 'S',
      M: 'M',
      L: 'L',
      XL: 'XL',
      XXL: '2XL',
      XXXL: '3XL',
    };
  }

  // Map local product variants to provider variants
  static mapVariants(localProduct, provider) {
    const variants = [];
    const colors =
      provider === 'printify'
        ? this.getPrintifyColors()
        : this.getPrintfulColors();

    if (
      localProduct.variants &&
      localProduct.variants.colors &&
      localProduct.variants.sizes
    ) {
      localProduct.variants.colors.forEach((color) => {
        localProduct.variants.sizes.forEach((size) => {
          if (colors[color.name] && this.getSizeMappings()[size]) {
            variants.push({
              color: color.name,
              size: size,
              colorHex: colors[color.name],
              mappedSize: this.getSizeMappings()[size],
              stock: color.stock || 0,
            });
          }
        });
      });
    }

    return variants;
  }
}

// Export classes
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { PODProductTemplates, PODVariantMappings };
} else {
  window.PODProductTemplates = PODProductTemplates;
  window.PODVariantMappings = PODVariantMappings;
}
