/**
 * @description Controlador Maestro Devlyn 360 - VERSIÓN INTEGRAL RESTAURADA Y OPTIMIZADA.
 */
public with sharing class TechProfile360Controller {

    @TestVisible private static List<UnifiedssotIndividualDev2__dlm> mockProfiles;
    @TestVisible private static List<SObject> mockOrders;
    @TestVisible private static List<SObject> mockOrderProducts;
    @TestVisible private static List<SObject> mockEngagements;
    @TestVisible private static List<SObject> mockCitas;
    @TestVisible private static List<SObject> mockQuotes;
    @TestVisible private static List<SObject> mockSubs;

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProfileData(String uid) {
        Map<String, Object> res = new Map<String, Object>();
        try {
            List<UnifiedssotIndividualDev2__dlm> profs = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c, Id_TuoTempo__c, FECHA_NACIMIENTO_dt__c, ssot__GenderId__c, CODIGO_POSTAL__c, ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__Id__c=:uid OR Id_POS__c=:uid LIMIT 1];
            if(!profs.isEmpty()) {
                UnifiedssotIndividualDev2__dlm r = profs[0];
                String uniId = r.ssot__Id__c;
                String realPhone = 'N/A';
                try {
                    for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c = \''+uniId+'\' LIMIT 1')) {
                        realPhone = (String)p.get('ssot__TelephoneNumber__c');
                    }
                } catch(Exception e) {}
                res.put('profile', new Map<String, Object>{'firstName'=>toTitleCase(r.ssot__FirstName__c), 'lastName'=>toTitleCase(r.ssot__LastName__c), 'idPos'=>r.Id_POS__c, 'email'=>r.Email__c, 'cp'=>r.CODIGO_POSTAL__c, 'gender'=>r.ssot__GenderId__c, 'age'=>calculateAge(r.FECHA_NACIMIENTO_dt__c), 'phone'=>realPhone});
            }
            return res;
        } catch (Exception e) { return res; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchProfilesGlobal(String term) {
        if (String.isBlank(term)) return new List<Map<String, Object>>();
        term = term.trim();
        List<String> tokens = term.split('\\s+');
        
        Set<String> idsFromPhones = new Set<String>();
        for(String t : tokens) {
            String cleanT = t.replaceAll('[^0-9]', '');
            if (cleanT.length() >= 7) {
                String phoneTerm = '%' + cleanT + '%';
                try {
                    for(SObject p : Database.query('SELECT ssot__PartyId__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__TelephoneNumber__c LIKE :phoneTerm LIMIT 200')) {
                        String indId = (String)p.get('ssot__PartyId__c');
                        if(String.isNotBlank(indId)) idsFromPhones.add(indId);
                    }
                } catch(Exception e) {}
            }
        }

        // FASE 1: AND
        String q1 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ';
        List<String> andConds = new List<String>();
        Map<String, String> bindMap = new Map<String, String>();
        for(Integer i=0; i<tokens.size(); i++) {
            String k = 'p'+i; bindMap.put(k, '%' + tokens[i].toUpperCase() + '%');
            andConds.add('(ssot__FirstName__c LIKE :'+k+' OR ssot__LastName__c LIKE :'+k+' OR Email__c LIKE :'+k+' OR Id_POS__c LIKE :'+k+')');
        }
        q1 += String.join(andConds, ' AND ') + ' LIMIT 200';
        List<UnifiedssotIndividualDev2__dlm> precisionResults = Database.queryWithBinds(q1, bindMap, AccessLevel.USER_MODE);

        // FASE 2: OR
        List<UnifiedssotIndividualDev2__dlm> broadResults = new List<UnifiedssotIndividualDev2__dlm>();
        if(precisionResults.size() < 200) {
            String q2 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE ';
            List<String> orConds = new List<String>();
            for(Integer i=0; i<tokens.size(); i++) orConds.add('(ssot__FirstName__c LIKE :p'+i+' OR ssot__LastName__c LIKE :p'+i+')');
            if(!idsFromPhones.isEmpty()) orConds.add('ssot__Id__c IN :idsFromPhones');
            q2 += '(' + String.join(orConds, ' OR ') + ') LIMIT ' + (200 - precisionResults.size());
            broadResults = Database.queryWithBinds(q2, bindMap, AccessLevel.USER_MODE);
        }

        Map<String, UnifiedssotIndividualDev2__dlm> uniqueMap = new Map<String, UnifiedssotIndividualDev2__dlm>();
        for(UnifiedssotIndividualDev2__dlm r : precisionResults) uniqueMap.put(r.ssot__Id__c, r);
        for(UnifiedssotIndividualDev2__dlm r : broadResults) uniqueMap.put(r.ssot__Id__c, r);

        Set<String> finalIds = uniqueMap.keySet();
        Map<String, String> phoneMap = new Map<String, String>();
        if(!finalIds.isEmpty()) {
            try {
                for(SObject p : Database.query('SELECT ssot__TelephoneNumber__c, ssot__PartyId__c FROM UnifiedssotContactPointPhoneDev2__dlm WHERE ssot__PartyId__c IN :finalIds')) {
                    phoneMap.put((String)p.get('ssot__PartyId__c'), (String)p.get('ssot__TelephoneNumber__c'));
                }
            } catch(Exception e) {}
        }

        List<SearchResultWrapper> wrappedResults = new List<SearchResultWrapper>();
        for(UnifiedssotIndividualDev2__dlm r : uniqueMap.values()) {
            wrappedResults.add(new SearchResultWrapper(r, tokens, phoneMap.get(r.ssot__Id__c)));
        }
        wrappedResults.sort();

        List<Map<String, Object>> finalResults = new List<Map<String, Object>>();
        for(SearchResultWrapper w : wrappedResults) {
            UnifiedssotIndividualDev2__dlm r = w.record;
            Map<String, Object> m = new Map<String, Object>();
            m.put('ssot__Id__c', r.ssot__Id__c);
            m.put('ssot__FirstName__c', toTitleCase(r.ssot__FirstName__c));
            m.put('ssot__LastName__c', toTitleCase(r.ssot__LastName__c));
            m.put('Email__c', r.Email__c);
            m.put('Id_POS__c', r.Id_POS__c);
            m.put('Telefono__c', phoneMap.containsKey(r.ssot__Id__c) ? phoneMap.get(r.ssot__Id__c) : 'N/A'); 
            finalResults.add(m);
        }
        return finalResults;
    }

    public class SearchResultWrapper implements Comparable {
        public UnifiedssotIndividualDev2__dlm record;
        public Integer score;

        public SearchResultWrapper(UnifiedssotIndividualDev2__dlm r, List<String> tokens, String phone) {
            this.record = r;
            this.score = calculateScore(r, tokens, phone);
        }

        private Integer calculateScore(UnifiedssotIndividualDev2__dlm r, List<String> tokens, String phone) {
            Integer s = 0;
            String fn = (r.ssot__FirstName__c ?? '').toUpperCase();
            String ln = (r.ssot__LastName__c ?? '').toUpperCase();
            String fullName = (fn + ' ' + ln).replaceAll('\\s+', ' ').trim();
            List<String> nameParts = fullName.split('\\s+');
            Set<String> nameSet = new Set<String>();
            for(String p : nameParts) nameSet.add(p);

            Integer matchedWords = 0;
            for(String t : tokens) if(nameSet.contains(t.toUpperCase())) matchedWords++;
            if(matchedWords == tokens.size()) s += 50000; else s += (matchedWords * 5000);

            String searchTerm = String.join(tokens, ' ').toUpperCase();
            if(fullName == searchTerm) s += 20000;
            if(fullName.contains(searchTerm)) s += 10000;

            Integer lastMatchedIdx = -1;
            for(String t : tokens) {
                String tu = t.toUpperCase();
                for(Integer i=0; i<nameParts.size(); i++) {
                    if(nameParts[i] == tu) {
                        s += 1000;
                        if(i == lastMatchedIdx + 1) s += 2000;
                        lastMatchedIdx = i; break;
                    }
                }
            }
            if(!tokens.isEmpty() && fn.startsWith(tokens[0].toUpperCase())) s += 5000;
            s -= (nameParts.size() * 10);
            return s;
        }

        public Integer compareTo(Object compareTo) {
            SearchResultWrapper other = (SearchResultWrapper)compareTo;
            if (this.score != other.score) return (this.score > other.score) ? -1 : 1;
            String thisFull = ((this.record.ssot__FirstName__c ?? '') + ' ' + (this.record.ssot__LastName__c ?? '')).toUpperCase();
            String otherFull = ((other.record.ssot__FirstName__c ?? '') + ' ' + (other.record.ssot__LastName__c ?? '')).toUpperCase();
            return thisFull.compareTo(otherFull);
        }
    }

    private static String toTitleCase(String input) {
        if(String.isBlank(input)) return '';
        List<String> words = input.toLowerCase().split('\\s+');
        List<String> properWords = new List<String>();
        for(String w : words) {
            if(w.length() > 0) properWords.add(w.substring(0,1).toUpperCase() + w.substring(1));
        }
        return String.join(properWords, ' ');
    }

    private static Integer calculateAge(Date dob) { if(dob==null) return 0; return dob.daysBetween(Date.today())/365; }
    private static String categorize(String d) { if(d==null) return 'Oftalmicos'; d=d.toLowerCase(); if(d.contains('solar')) return 'Solares'; if(d.contains('contacto')) return 'LentesContacto'; return 'Oftalmicos'; }
}