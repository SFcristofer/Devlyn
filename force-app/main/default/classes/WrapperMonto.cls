public with sharing class WrapperMonto {

    public Set<String> activeRecords;
    
    public String mensaje;
	public Integer status;
	public Tabla tabla;

	public class Tabla {
		public List<Columnas> columnas;
		public List<Registros> registros;
	}

	public class Columnas {
		public Integer posicion;
		public String nombre;
	}

	public class Celdas {
		public Integer columna;
		public String dato;
	}

	public class Registros {
		public Integer index;
		public List<Celdas> celdas;
	}

	public WrapperMonto parse(String json) {
		return (WrapperMonto) System.JSON.deserialize(json, WrapperMonto.class);
	}

	public Map<Decimal,Opportunity> getMapOpportunity(){
		Map<Decimal, Opportunity> mapOpportunity = new Map<Decimal, Opportunity>();
		for (Opportunity opp : [SELECT Id, Numero_de_convenio__c FROM Opportunity WHERE Numero_de_convenio__c != null]) {
			mapOpportunity.put(opp.Numero_de_convenio__c, opp);
		}
		return mapOpportunity;
	}

    public List<Monto__c> createObject(WrapperMonto wrapper){
		System.debug('Numero de registros '+ wrapper.tabla.registros.size());
		this.activeRecords = new Set<String>();
		Map<Decimal, Opportunity> mapOpportunity = getMapOpportunity();
		List<Monto__c> listAccount = new List<Monto__c>();
		for (Registros registro : wrapper.Tabla.registros) {
			// System.debug(registro);
			// System.debug(registro.index);
			Monto__c record = new Monto__c();
            String externalId = String.valueOf(registro.index);
			this.activeRecords.add(externalId);
			
			record.IsActive__c = true;
			record.Sincronizado__c = true;
			record.isError__c = false;
			record.ExternalId__c = externalId;
			Map<Integer, Celdas> mapCeldas = new Map<Integer, Celdas>();
            for (Celdas celda : registro.celdas) {
                mapCeldas.put(celda.columna, celda);
            }
			record.Numero_de_Convenio__c= mapCeldas.get(4).dato;
			if(String.isNotBlank(record.Numero_de_Convenio__c) && record.Numero_de_Convenio__c.isNumeric()){
				Opportunity opp=mapOpportunity.get(Decimal.valueOf(record.Numero_de_Convenio__c));
				if(opp != null){
					record.Oportunidad__c = opp.Id;
				}
			}
			record.VP__c = mapCeldas.get(1).dato;
			record.Metodo_de_Pago_POS__c = mapCeldas.get(2).dato;
			record.Nombre_Metodo_de_Pago__c= mapCeldas.get(3).dato;
			
			record.Valido_de__c= ETC_UtilityCallout.getDateFormated(mapCeldas.get(5).dato);
			record.Valido_a__c = ETC_UtilityCallout.getDateFormated(mapCeldas.get(6).dato);
			record.Tipo_Cuenta_Cargo__c= mapCeldas.get(7).dato;
			record.Numero_de_Cuenta_Cargo__c = mapCeldas.get(8).dato;
			record.DescCta__c = mapCeldas.get(9).dato;
			record.Tipo_Cuenta_Abono__c = mapCeldas.get(10).dato;
			record.Numero_de_Cuenta_Abono__c = mapCeldas.get(11).dato;
			record.DescCta2__c = mapCeldas.get(12).dato;
			record.Consolidado__c = mapCeldas.get(13).dato;
			record.Total_Not_Cred__c =  String.isBlank(mapCeldas.get(14).dato) || !mapCeldas.get(14).dato.isNumeric() ? 0.0:Decimal.valueOf(mapCeldas.get(14).dato);
			record.Total_Factura__c= String.isBlank(mapCeldas.get(15).dato) || !mapCeldas.get(15).dato.isNumeric() ? 0.0:Decimal.valueOf(mapCeldas.get(15).dato);
			record.Total_Pagado__c= String.isBlank(mapCeldas.get(16).dato) || !mapCeldas.get(16).dato.isNumeric() ? 0.0:Decimal.valueOf(mapCeldas.get(16).dato);
			
			listAccount.add(record);
		}

		return listAccount;
	}

}