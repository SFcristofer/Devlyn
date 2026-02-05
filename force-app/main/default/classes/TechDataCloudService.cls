/**
 * @description Service class to handle Data Cloud Query API logic for Devlyn.
 * Separates business logic and DMO queries from the LWC Controller.
 * @author Cristofer Contreras
 * @email cristofer.contreras@technovalue.com.mx
 */
public with sharing class TechDataCloudService {

    /**
     * @description Fetches patient data from Data Cloud DMOs.
     * @param recordId The Unified Individual ID or related Record ID.
     * @return Map containing the mapped fields for the UI.
     */
    public static Map<String, Object> getPatientProfile(String recordId) {
        // En producción, aquí se ejecutaría:
        // String query = 'SELECT ssot__FirstName__c, ssot__BirthDate__c, Antecedentes_Medicos__c, ID_POS__c FROM ssot__Individual__dlm WHERE ...';
        // return executeDataCloudQuery(query);
        
        return getMockData(recordId);
    }

    /**
     * @description Calculates age based on a BirthDate.
     */
    public static Integer calculateAge(Date birthDate) {
        if (birthDate == null) return 0;
        return Date.today().year() - birthDate.year();
    }

    /**
     * @description Mock data generator following Devlyn's requirements from text.txt.
     */
    private static Map<String, Object> getMockData(String recordId) {
        Date mockBirthDate = Date.newInstance(1988, 3, 25);
        
        return new Map<String, Object>{
            // Información General
            'firstName' => 'Cliente Unificado Devlyn',
            'lastName' => 'Pérez García',
            'age' => calculateAge(mockBirthDate),
            'gender' => 'Masculino',
            'zipCode' => '06700',
            'email' => 'cliente.unificado@example.com',
            'phone' => '55-1234-5678',
            'idPos' => 'DEV-90044',
            
            // Resumen del Cliente
            'totalSales' => 12500.00,
            'orderCount' => 4,
            'avgTicket' => 3125.00,
            'daysSinceLastPurchase' => 15,
            'lastBranch' => 'Madero Centro',
            'lastCategory' => 'Oftálmicos',

            // Resumen de Compras - Retail
            'retailTotal' => 8500.00,
            'retailCategories' => new Map<String, Integer>{
                'Oftalmicos' => 2,
                'LentesContacto' => 1,
                'Solares' => 0
            },

            // Resumen de Compras - Ecommerce
            'ecommerceTotal' => 4000.00,
            'ecommerceCategories' => new Map<String, Integer>{
                'Oftalmicos' => 0,
                'LentesContacto' => 1,
                'Solares' => 1
            },

            // Otros datos existentes
            'medicalHistory' => new List<String>{'Diabetes', 'Astigmatismo'},
            'clinicalNotes' => 'Paciente requiere seguimiento por alta graduación en lente de contacto.',
            'graduations' => new List<Map<String, Object>>{
                new Map<String, Object>{'date' => '2023-01-01', 'value' => 2.00},
                new Map<String, Object>{'date' => '2024-01-01', 'value' => 2.25},
                new Map<String, Object>{'date' => '2025-01-01', 'value' => 2.50}
            },
            'familyRelations' => new List<Map<String, String>>{
                new Map<String, String>{'name' => 'Ana Pérez', 'relation' => 'Esposa', 'id' => '001X...'}
            }
        };
    }
}