@RestResource(urlMapping='/Tech360/Search/*')
global with sharing class TechDataCloudRest {

    @HttpGet
    global static void search() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        try {
            // Obtener el término de búsqueda de la URL (?term=Rafael+Lopez)
            String searchTerm = req.params.get('term');
            
            if (String.isBlank(searchTerm)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{'error' => 'El parámetro term es obligatorio'}));
                return;
            }

            // Llamar a la lógica inteligente que ya perfeccionamos
            List<Map<String, Object>> searchResults = TechProfile360Controller.searchProfilesGlobal(searchTerm);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(searchResults));
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{'error' => e.getMessage()}));
        }
    }
}