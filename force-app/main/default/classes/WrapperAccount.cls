public with sharing class WrapperAccount {

	public Set<String> activeRecords;

    public String customId;
	public Integer IdReferencia;
	public Integer IdCliente;
	public String TipoMovimiento;
	public Integer OrganizacionVentas;
	public String IdPais;
	public String Nombre1;
	public String Nombre2;
	public String Publacion;
	public Integer IdDireccionMDS;
	public String CP;
	public String IdEstado;
	public Integer Telefono1;
	public String Calle;
	public String NumInterior;
	public String NumExterior;
	public String Estado;
	public String ClaveTratamiento;
	public String FechaCreacion;
	public String IdGrupo;
	public String MunicipioDelegacion;
	public String RFC;
	public String ClaveRegimen;
	public Integer Telefono2;
	public String PersonaFisica;
	public String GrupoInputacion;
	public String ViasPago;
	public String CDis;
	public String ClaveSector;
	public String ClaveCondicionesPago;
	public Decimal IDCodPostal_MDS;
	
	public List<WrapperAccount> parse(String json) {
		json = json.replaceAll('\\$id', 'customId');
		return (List<WrapperAccount>) System.JSON.deserialize(json, List<WrapperAccount>.class);
	}

	public List<Account> createObject(List<WrapperAccount> listWrapperAccount){
		System.debug('Numero de clientes '+ listWrapperAccount.size());
		this.activeRecords = new Set<String>();

		List<Account> listAccount = new List<Account>();
		for (WrapperAccount wrapperAccount : listWrapperAccount) {
			System.debug(wrapperAccount);
			System.debug(wrapperAccount.IdReferencia);
			Account account = new Account();
			// account.IdCliente = wrapperAccount.IdCliente;
			// account.TipoMovimiento = wrapperAccount.TipoMovimiento;
			String externalId = String.valueOf(wrapperAccount.IdReferencia);
			activeRecords.add(externalId);
			account.isActive__c = true;
			account.Sincronizado_SAP__c = true;
			account.ExternalId__c = externalId;
			account.IdReferencia__c = String.valueOf(wrapperAccount.IdReferencia);
			account.Id_Cliente__c = String.valueOf(wrapperAccount.IdCliente);
			// account.IdReferencia__c = String.valueOf(wrapperAccount.IdCliente);
			account.Organizacion_de_Ventas__c = String.valueOf(wrapperAccount.OrganizacionVentas);
			account.IdPais__c = wrapperAccount.IdPais;
			account.Name = wrapperAccount.Nombre1;
			account.Complemento_nombre_del_cliente__c = wrapperAccount.Nombre2;
			account.BillingCity = wrapperAccount.Publacion;
			account.Id_Direccion__c = wrapperAccount.IdDireccionMDS;
			account.BillingPostalCode = wrapperAccount.CP;
			account.Id_Estado__c = wrapperAccount.IdEstado;
			account.Phone = String.valueOf(wrapperAccount.Telefono1);
			account.BillingStreet = wrapperAccount.Calle;
			account.Num_Interior__c = wrapperAccount.NumInterior;
			account.Num_Exterior__c = wrapperAccount.NumExterior;
			account.BillingState = wrapperAccount.Estado;
			account.Tratamiento__c = wrapperAccount.ClaveTratamiento;
			account.Fecha_de_Creacion__c = System.now();
			account.Grupo_de_Cuentas__c = wrapperAccount.IdGrupo;
			account.Municipio_Delegacion__c = wrapperAccount.MunicipioDelegacion;
			account.RFC__c = wrapperAccount.RFC;
			account.Regimen__c = wrapperAccount.ClaveRegimen;
			account.Telefono_2__c = String.valueOf(wrapperAccount.Telefono2);
			account.Persona_Fisica__c = wrapperAccount.PersonaFisica=='X'?true:false;
			account.Tipo_de_Clente__c = wrapperAccount.GrupoInputacion;
			account.Via_Pago__c = wrapperAccount.ViasPago;
			account.Canal_de_Distribucion__c = wrapperAccount.CDis;
			account.Sector__c = wrapperAccount.ClaveSector;
			account.Condiciones_de_Pago__c = wrapperAccount.ClaveCondicionesPago;
			account.IDCodPostal_MDS__c = wrapperAccount.IDCodPostal_MDS;
			listAccount.add(account);
		}

		return listAccount;
	}
}