// Mock data for resources until backend is ready
import '../../domain/models/resource.dart';

class ResourcesRepository {
  // Mock data - will be replaced with API calls
  List<Resource> getMockResources() {
    return [
      // Getting Started: Registration & Licensing
      Resource(
        id: 1,
        title: 'NEPC Exporter Registration Guide & e-Registration Portal',
        category: 'registration-licensing',
        type: 'link',
        description:
            'Primary portal and guide for registering as a Nigerian exporter.',
        fileUrl: 'https://nepc.gov.ng/ereg/exporter',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 2,
        title: 'CAC Business Registration Guide (Company Incorporation)',
        category: 'registration-licensing',
        type: 'link',
        description:
            'Official guide for legal business incorporation in Nigeria.',
        fileUrl: 'https://cac.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 3,
        title: 'NAFDAC Product Registration Guidelines',
        category: 'registration-licensing',
        type: 'link',
        description:
            'Regulatory requirements for food and drug product registration.',
        fileUrl: 'https://nafdac.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 4,
        title: 'SON Product Standards & Certification (MANCAP / NIS)',
        category: 'registration-licensing',
        type: 'link',
        description: 'Standards for manufactured products in Nigeria.',
        fileUrl: 'https://son.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 5,
        title: 'Nigeria Trade Information Portal',
        category: 'registration-licensing',
        type: 'link',
        description: 'Step-by-step export procedures by product category.',
        fileUrl: 'https://nigeriainfotrade.fmiti.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 6,
        title: 'NEPC Export Plan Template',
        category: 'registration-licensing',
        type: 'pdf',
        description:
            'A structured template to help you build your export strategy.',
        fileUrl:
            'https://nepc.gov.ng/cms/wp-content/uploads/2018/06/Export-Plan-Template-NEPC.pdf',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),

      // Export Documentation & Procedures
      Resource(
        id: 7,
        title: 'NEPC Export Documents & Procedures Guide',
        category: 'documentation-procedures',
        type: 'link',
        description:
            'Comprehensive list of required shipping and financial documents.',
        fileUrl: 'https://nepc.gov.ng/get-started/export-documents-procedures',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 8,
        title: 'Nigeria Export Proceeds (NXP) Form Guide — CBN',
        category: 'documentation-procedures',
        type: 'link',
        description: 'Guide on processing mandatory export proceed forms.',
        fileUrl: 'https://cbn.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 9,
        title: 'Harmonised System (HS) Code Lookup Tool',
        category: 'documentation-procedures',
        type: 'link',
        description:
            'Identify the correct international trade classification for your products.',
        fileUrl: 'https://nepc.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 10,
        title: 'Certificate of Origin Application Guide (NACCIMA)',
        category: 'documentation-procedures',
        type: 'link',
        description: 'How to apply for proofs of Nigerian origin.',
        fileUrl: 'https://naccima.com',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 11,
        title: 'Clean Certificate of Inspection (CCI) — Pre-Shipment Agents',
        category: 'documentation-procedures',
        type: 'link',
        description:
            'Information on clean certificates of inspection requirements.',
        fileUrl: 'https://angliainternational.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 12,
        title: 'Incoterms 2020 Quick Reference Guide',
        category: 'documentation-procedures',
        type: 'link',
        description:
            'International rules for the interpretation of trade terms.',
        fileUrl: 'https://iccwbo.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 13,
        title: 'Phytosanitary / SPS Certificate Guide — NAQS',
        category: 'documentation-procedures',
        type: 'link',
        description:
            'Sanitary and phytosanitary requirements for agricultural exports.',
        fileUrl: 'https://naqs.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),

      // Export Financing & Incentives
      Resource(
        id: 14,
        title: 'CBN Non-Oil Export Stimulation Facility (NESF) Guidelines',
        category: 'financing-incentives',
        type: 'link',
        description: 'Financial support options for non-oil exporters.',
        fileUrl: 'https://cbn.gov.ng/DFD/manufacturing/nesf.html',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 15,
        title: 'Export Expansion Grant (EEG) Scheme Guidelines',
        category: 'financing-incentives',
        type: 'link',
        description: 'Grants and incentives to encourage Nigerian exports.',
        fileUrl:
            'https://nepc.gov.ng/blog/export-incentive/export-expansion-grant',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 16,
        title: 'NEXIM Bank Products & Services Guide',
        category: 'financing-incentives',
        type: 'link',
        description: 'Export credit, insurance, and guarantee services.',
        fileUrl: 'https://neximbank.com.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 17,
        title: 'RT200 FX Programme Overview — CBN',
        category: 'financing-incentives',
        type: 'link',
        description: 'Repatriation scheme for non-oil export proceeds.',
        fileUrl: 'https://cbn.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 18,
        title: 'Manufacture-in-Bond Scheme (MIBS) Guidelines',
        category: 'financing-incentives',
        type: 'link',
        description: 'Customs incentives for domestic manufacturing.',
        fileUrl: 'https://customs.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 19,
        title: 'AfCFTA Opportunities for Nigerian Exporters — NEPC',
        category: 'financing-incentives',
        type: 'link',
        description: 'Overview of trade agreements across Africa.',
        fileUrl: 'https://nepc.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),

      // Quality, Packaging & Labelling Standards
      Resource(
        id: 20,
        title: 'NAFDAC Packaging & Labelling Requirements for Food',
        category: 'standards-quality',
        type: 'link',
        description: 'Specific standards for food export labels and packs.',
        fileUrl: 'https://nafdac.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 21,
        title: 'SON Nigerian Industrial Standards (NIS)',
        category: 'standards-quality',
        type: 'link',
        description: 'Product-specific industrial standards for exports.',
        fileUrl: 'https://son.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 22,
        title: 'Codex Alimentarius — International Food Standards',
        category: 'standards-quality',
        type: 'link',
        description:
            'Global reference point for consumers, food producers and trade.',
        fileUrl: 'http://www.fao.org/fao-who-codexalimentarius',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 23,
        title: 'ITC Standards Map — Collaborative Tool',
        category: 'standards-quality',
        type: 'link',
        description: 'Search voluntary standards by product and market.',
        fileUrl: 'https://standardsmap.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 24,
        title: 'EU Market Access Requirements for Nigerian Products',
        category: 'standards-quality',
        type: 'link',
        description:
            'Regulatory requirements for exporting to the European Union.',
        fileUrl: 'https://trade.ec.europa.eu/access-to-markets',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 25,
        title: 'US FDA Requirements for Food Imports',
        category: 'standards-quality',
        type: 'link',
        description: 'US food import regulations (FSVP, Prior Notice).',
        fileUrl: 'https://fda.gov/food/importing-food-products',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 26,
        title: 'GS1 Nigeria — Barcode Registration',
        category: 'standards-quality',
        type: 'link',
        description: 'Universal barcodes for international retail products.',
        fileUrl: 'https://gs1ng.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 27,
        title: 'Good Manufacturing Practice (GMP) Self-Assessment',
        category: 'standards-quality',
        type: 'link',
        description: 'WHO/FAO checklist for manufacturing compliance.',
        fileUrl: 'https://who.int/publications',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),

      // Market Intelligence & Trade Platforms
      Resource(
        id: 28,
        title: 'ITC Trade Map — Export/Import Statistics',
        category: 'market-intelligence',
        type: 'link',
        description: 'Strategic market statistics and trade balance data.',
        fileUrl: 'https://trademap.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 29,
        title: 'NEPC Buy-From-Nigeria Portal',
        category: 'market-intelligence',
        type: 'link',
        description: 'Direct B2B portal to connect with verified exporters.',
        fileUrl: 'https://buyfromnigeria.com',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 30,
        title: 'ITC Market Access Map — Tariffs & Barriers',
        category: 'market-intelligence',
        type: 'link',
        description: 'Analyze import duties and trade barriers by country.',
        fileUrl: 'https://macmap.org',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 31,
        title: 'AfCFTA Tariff Concession Schedules',
        category: 'market-intelligence',
        type: 'link',
        description: 'Detailed tariff schedules under the African agreement.',
        fileUrl: 'https://afcfta.au.int',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 32,
        title: 'Alibaba.com / TradeKey B2B Overview',
        category: 'market-intelligence',
        type: 'link',
        description: 'Guide to popular B2B export platforms.',
        fileUrl: 'https://alibaba.com',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 33,
        title: 'NEPC E-Learning Export Courses',
        category: 'market-intelligence',
        type: 'link',
        description: 'Free online training for aspiring exporters.',
        fileUrl: 'https://nepc.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 34,
        title: 'ITC SheTrades — Nigeria Hub',
        category: 'market-intelligence',
        type: 'link',
        description: 'Specialized support for women-led export businesses.',
        fileUrl: 'https://shetrades.com',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 35,
        title: 'NEPC Product Profiles',
        category: 'market-intelligence',
        type: 'link',
        description: 'Market data for Cocoa, Cashew, Ginger, Sesame, and Shea.',
        fileUrl: 'https://nepc.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 36,
        title: 'ITC Export Potential Map',
        category: 'market-intelligence',
        type: 'link',
        description: 'Identify untapped export potentials and diversification.',
        fileUrl: 'https://exportpotential.intracen.org/en/',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),

      // Export Logistics & Customs
      Resource(
        id: 37,
        title: 'Nigeria Customs Service — Procedures & Tariffs',
        category: 'logistics-customs',
        type: 'link',
        description: 'Official customs regulations and export tariffs.',
        fileUrl: 'https://customs.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 38,
        title: 'NEPC Export Pricing Guide',
        category: 'logistics-customs',
        type: 'link',
        description: 'Strategies for pricing your products for global markets.',
        fileUrl: 'https://nepc.gov.ng/get-started/export-pricing',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 39,
        title: 'NEPC Logistics & Freight Guide',
        category: 'logistics-customs',
        type: 'link',
        description: 'Managing shipping, cargo, and freight procedures.',
        fileUrl: 'https://nepc.gov.ng/get-started/logistics-freights',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 40,
        title: 'NEPC Legal Issues in Export Guide',
        category: 'logistics-customs',
        type: 'link',
        description: 'Contract law and legal protections for exporters.',
        fileUrl: 'https://nepc.gov.ng/get-started/legal-issues',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
      Resource(
        id: 41,
        title: 'NEPC BSO (Business Support Organisation) Directory',
        category: 'logistics-customs',
        type: 'link',
        description: 'Directory of support organisations for exporters.',
        fileUrl: 'https://nepc.gov.ng',
        createdAt: DateTime.now(),
        downloadCount: 0,
      ),
    ];
  }

  Future<List<Resource>> getResources(
      {String? category, String? search}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var resources = getMockResources();

    // Filter by category
    if (category != null && category.isNotEmpty) {
      resources = resources.where((r) => r.category == category).toList();
    }

    // Filter by search query
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      resources = resources
          .where((r) =>
              r.title.toLowerCase().contains(query) ||
              (r.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return resources;
  }

  Future<void> downloadResource(int resourceId) async {
    // Simulate download - in real app, this would trigger actual download
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Implement actual download logic
  }

  Future<void> toggleBookmark(int resourceId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Implement bookmark API call
  }
}
