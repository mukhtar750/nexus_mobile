import '../domain/models/product_comparison.dart';

class ProductComparisonData {
  // Main detailed comparisons for interactive slider
  static final List<ProductComparison> detailedComparisons = [
    ProductComparison(
      title: 'Palm Oil Packaging Transformation',
      beforeLabel: 'Basic Packaging',
      afterLabel: 'Export-Ready',
      beforeImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/palm_oil_before_1770806397494.png',
      afterImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/palm_oil_after_1770806414303.png',
      beforeDescription:
          'Generic plastic container with hand-written label, no brand identity, unclear product information.',
      afterDescription:
          'Professional branded bottle with clear labeling, certification marks, nutritional info, and attractive design.',
      improvements: [
        'Professional branded label with logo and color scheme',
        'Clear product information (ingredients, weight, origin)',
        'Certification marks (organic, fair trade, quality standards)',
        'Multilingual labeling for international markets',
        'Tamper-evident seal and safety features',
        'Barcode and batch number for traceability',
        'Attractive design that stands out on shelves',
      ],
    ),
    ProductComparison(
      title: 'Groundnut (Peanuts) Packaging Upgrade',
      beforeLabel: 'Local Market',
      afterLabel: 'International Standard',
      beforeImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/groundnut_before_1770806492952.png',
      afterImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/groundnut_after_1770806509068.png',
      beforeDescription:
          'Simple plastic bag with basic label, minimal product information, no branding.',
      afterDescription:
          'Stand-up pouch with professional design, clear window, comprehensive labeling, and strong brand presence.',
      improvements: [
        'Stand-up pouch for better shelf presentation',
        'Clear window to show product quality',
        'Professional graphics and brand identity',
        'Allergen warnings and nutritional facts',
        'Resealable zipper for freshness',
        'Country of origin and certification logos',
        'QR code for product traceability',
      ],
    ),
    ProductComparison(
      title: 'Shea Butter Branding Evolution',
      beforeLabel: 'Unbranded',
      afterLabel: 'Premium Brand',
      beforeImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/shea_butter_before_1770806524087.png',
      afterImageUrl:
          '/Users/apple/.gemini/antigravity/brain/aff03891-1c3a-46b1-8859-199edda5f4c6/shea_butter_after_1770806539258.png',
      beforeDescription:
          'Plain container with minimal labeling, looks homemade, no differentiation from competitors.',
      afterDescription:
          'Premium jar with elegant branding, story-telling elements, certification badges, and luxury appeal.',
      improvements: [
        'Premium glass jar with professional cap',
        'Elegant label design with brand story',
        'Organic and fair-trade certifications prominently displayed',
        'Usage instructions and benefits clearly stated',
        'Social impact story connecting to producers',
        'Consistent brand colors and typography',
        'Shelf-ready packaging that commands premium pricing',
      ],
    ),
  ];

  // Quick examples for carousel
  static final List<ProductComparison> quickExamples = [
    ProductComparison(
      title: 'Cashew Nuts Packaging',
      beforeDescription: 'Basic plastic bag',
      afterDescription: 'Branded premium packaging',
      improvements: [
        'Professional branding',
        'Nutritional information',
        'Resealable packaging',
      ],
    ),
    ProductComparison(
      title: 'Dried Hibiscus Labeling',
      beforeDescription: 'Hand-written labels',
      afterDescription: 'Printed professional labels',
      improvements: [
        'Clear product name and origin',
        'Brewing instructions',
        'Health benefits highlighted',
      ],
    ),
    ProductComparison(
      title: 'Cocoa Powder Branding',
      beforeDescription: 'Generic container',
      afterDescription: 'Branded tin with design',
      improvements: [
        'Premium tin container',
        'Brand story and origin',
        'Recipe suggestions included',
      ],
    ),
    ProductComparison(
      title: 'Dried Mango Slices',
      beforeDescription: 'Simple plastic wrap',
      afterDescription: 'Transparent pouch with branding',
      improvements: [
        'Product visibility',
        'Nutritional facts',
        'Storage instructions',
      ],
    ),
  ];
}
