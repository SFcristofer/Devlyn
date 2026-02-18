import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFullData from '@salesforce/apex/TechHelper.getFullData';

export default class TechPatient360Profile extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track activeTab = 'expediente';

    // Estados de secciones expandibles
    @track isAntecedenteOpen = false;
    @track isDriverVisualOpen = false;
    @track isPreguntasPoderOpen = false;
    @track isGraduacionesOpen = false;
    @track isFamiliaOpen = false;

    // Datos del Paciente inicializados
    @track patientData = {
        firstName: '', lastName: '', age: 0, gender: '', email: '', phone: 'N/A', idPos: '', cp: '',
        totalSales: 0, orderCount: 0, avgTicket: 0, lastBranch: 'N/A', lastCategory: 'N/A',
        retailTotal: 0, ecommerceTotal: 0,
        retailCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        ecommerceCategories: { Solares: 0, LentesContacto: 0, Oftalmicos: 0 },
        medicalHistory: [], medicalNotes: '', visualDriver: {}, powerQuestions: {}, familyRelations: []
    };

    @track orders = [];
        @track appointments = []; @track quotes = []; @track subscriptions = []; @track campaigns = [];
        @track diagnoses = []; @track lastDiagnosisDate = 'N/A'; @track lastExamDate = 'N/A';
        @track rfmHistory = [];
        @track rfmRetail = { solaresLabel: 'Sin Datos' };
    @track rfmEcommerce = { solaresLabel: 'Sin Datos' };
    @track einsteinScore = { propensidadClick: 'Media', propensidadAbrir: 'Alta' };

    _wiredResult;

    @wire(getFullData, { uid: '$recordId' })
    wiredData(result) {
        this._wiredResult = result;
        if (result.data) {
            const d = result.data;
            if (d.profile) this.patientData = { ...this.patientData, ...d.profile };
            if (d.metrics) this.patientData = { ...this.patientData, ...d.metrics };
            
            // Órdenes Procesadas (VISTA MEJORADA)
            const formatCurrency = (val) => Number(val || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
            const formatDate = (dateStr) => {
                if (!dateStr || dateStr === 'N/A') return 'Sin fecha';
                const d = new Date(dateStr);
                return isNaN(d.getTime()) ? dateStr : d.toLocaleDateString('es-MX');
            };

            this.orders = (d.orders || []).map(o => ({
                ...o,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                detailsClass: 'orden-details collapsed',
                totalFormatted: formatCurrency(o.total),
                fechaCompraFormatted: formatDate(o.fechaCompra),
                productos: (o.productos || []).map(p => ({
                    nombre: p.nombre || 'Producto',
                    sku: p.sku || 'S/SKU',
                    cantidad: p.cantidad || 1,
                    precioTotalFormatted: formatCurrency(p.precioTotal)
                }))
            }));

            // Campañas Procesadas
            this.campaigns = (d.campaigns || []).map((c, cIdx) => ({
                ...c,
                isExpanded: false,
                chevronIcon: 'utility:chevrondown',
                detailsClass: 'campana-details collapsed',
                envios: (c.envios || []).map((e, eIdx) => ({
                    ...e,
                    asunto: e.asunto || c.nombre || 'Correo Devlyn',
                    asuntoCompleto: e.asunto || c.nombre,
                    desde: 'Devlyn',
                    fechaEnvio: e.fechaFormateada || 'N/A',
                    icono: 'utility:email',
                    isExpanded: false,
                    chevronIcon: 'utility:chevrondown',
                    detailsClass: 'envio-details collapsed',
                    uniqueKey: e.uniqueKey || `env-${cIdx}-${eIdx}`
                }))
            }));

            // Cotizaciones Procesadas (VISTA MEJORADA)
            this.quotes = (d.quotes || []).map(q => {
                const formatDate = (dateStr) => {
                    if (!dateStr || dateStr === 'N/A') return 'Sin fecha';
                    const d = new Date(dateStr);
                    return isNaN(d.getTime()) ? dateStr : d.toLocaleDateString('es-MX');
                };

                return {
                    ...q,
                    presupuestoId: q.presupuestoId || 'S/N',
                    status: 'Pendiente',
                    total: q.total ? Number(q.total).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' }) : '$0.00',
                    fecha: formatDate(q.fecha),
                    fechaExpiracion: formatDate(q.vigencia),
                    sucursal: q.sucursal || 'Sucursal Devlyn',
                    isExpanded: false,
                    chevronIcon: 'utility:chevrondown',
                    productosClass: 'cotizacion-productos collapsed',
                    productos: (q.productos || []).map(p => ({
                        nombre: p.nombre || 'Sin nombre',
                        sku: p.sku || 'S/SKU',
                        cantidad: p.cantidad || 1,
                        precioTotalFormatted: p.precioTotal ? Number(p.precioTotal).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' }) : '$0.00'
                    }))
                };
            });

            this.appointments = d.appointments || [];
            this.subscriptions = d.subscriptions || [];

            // Mapeo de Scores de Marketing y RFM
            if(d.marketingScores) {
                const s = d.marketingScores;
                this.einsteinScore = { propensidadClick: s.propensidadClick || 'Media', propensidadAbrir: s.propensidadAbrir || 'Media' };
                
                // Historial para uso interno o futuro
                this.rfmHistory = (s.rfmHistory || []).map(h => ({
                    ...h,
                    lastDateFormatted: h.last ? formatDate(h.last) : 'Sin actividad'
                }));

                // Restauramos rfmRetail y rfmEcommerce para la vista de tabla
                this.rfmRetail = {
                    solares: this.rfmHistory[0]?.score || '1/5',
                    lentesContacto: this.rfmHistory[1]?.score || '1/5',
                    oftalmicos: this.rfmHistory[2]?.score || '1/5',
                    solaresLabel: this.rfmHistory[0]?.label || 'Inactivo',
                    lentesContactoLabel: this.rfmHistory[1]?.label || 'Potencial',
                    oftalmicosLabel: this.rfmHistory[2]?.label || 'Nuevo',
                    ultimaVenta: this.rfmHistory[2]?.lastDateFormatted || 'Sin datos'
                };
                this.rfmEcommerce = { ...this.rfmRetail, solares: '1/5', solaresLabel: 'Inactivo' }; // Ejemplo para ecommerce
            }

            if (d.medical) {
                const m = d.medical;
                if (m.diagnosis) {
                    this.diagnoses = m.diagnosis.MIOPIA__c ? ['Miopía'] : ['Sano'];
                    this.lastDiagnosisDate = m.diagnosis.FECHA__c || 'N/A';
                    this.lastExamDate = m.lastExam || 'N/A';
                }
                if (m.antecedents) {
                    let h = [];
                    if (m.antecedents.DIABETES__c) h.push('Diabetes');
                    this.patientData.medicalHistory = h;
                    this.patientData.medicalNotes = m.antecedents.NOTAS__c || 'Sin notas';
                }
                this.patientData.visualDriver = m.visualDriver || {};
            }
            this.isLoading = false;
        } else if (result.error) {
            console.error('Error loading data:', result.error);
            this.isLoading = false;
        }
    }

    // Handlers de Pestañas
    handleTabExpediente() { this.activeTab = 'expediente'; }
    handleTabOrdenes() { this.activeTab = 'ordenes'; }
    handleTabCitas() { this.activeTab = 'citas'; }
    handleTabCotizaciones() { this.activeTab = 'cotizaciones'; }
    handleTabSuscripciones() { this.activeTab = 'suscripciones'; }
    handleTabEnviosMarketing() { this.activeTab = 'enviosMarketing'; }

    // Getters de Visibilidad
    get isTabExpediente() { return this.activeTab === 'expediente'; }
    get isTabOrdenes() { return this.activeTab === 'ordenes'; }
    get isTabCitas() { return this.activeTab === 'citas'; }
    get isTabCotizaciones() { return this.activeTab === 'cotizaciones'; }
    get isTabSuscripciones() { return this.activeTab === 'suscripciones'; }
    get isTabEnviosMarketing() { return this.activeTab === 'enviosMarketing'; }

    get hasOrders() { return this.orders && this.orders.length > 0; }
    get hasAppointments() { return this.appointments && this.appointments.length > 0; }
    get hasQuotes() { return this.quotes && this.quotes.length > 0; }
    get hasSubscriptions() { return this.subscriptions && this.subscriptions.length > 0; }
    get hasCampaigns() { return this.campaigns && this.campaigns.length > 0; }
    get hasFamilyRelations() { return this.patientData.familyRelations && this.patientData.familyRelations.length > 0; }
    get hasVisualDriver() { return Object.keys(this.patientData.visualDriver).length > 0; }
    get hasPowerQuestions() { return Object.keys(this.patientData.powerQuestions).length > 0; }
    get hasGraduations() { return false; }

    get tabExpedienteClass() { return this.activeTab === 'expediente' ? 'tab-button active' : 'tab-button'; }
    get tabOrdenesClass() { return this.activeTab === 'ordenes' ? 'tab-button active' : 'tab-button'; }
    get tabCitasClass() { return this.activeTab === 'citas' ? 'tab-button active' : 'tab-button'; }
    get tabCotizacionesClass() { return this.activeTab === 'cotizaciones' ? 'tab-button active' : 'tab-button'; }
    get tabSuscripcionesClass() { return this.activeTab === 'suscripciones' ? 'tab-button active' : 'tab-button'; }
    get tabEnviosMarketingClass() { return this.activeTab === 'enviosMarketing' ? 'tab-button active' : 'tab-button'; }

    get antecedenteContentClass() { return this.isAntecedenteOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get driverVisualContentClass() { return this.isDriverVisualOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get preguntasPoderContentClass() { return this.isPreguntasPoderOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get graduacionesContentClass() { return this.isGraduacionesOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }
    get familiaContentClass() { return this.isFamiliaOpen ? 'capsule-content expanded' : 'capsule-content collapsed'; }

    get antecedenteIcon() { return this.isAntecedenteOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get driverVisualIcon() { return this.isDriverVisualOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get preguntasPoderIcon() { return this.isPreguntasPoderOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get graduacionesIcon() { return this.isGraduacionesOpen ? 'utility:chevronup' : 'utility:chevrondown'; }
    get familiaIcon() { return this.isFamiliaOpen ? 'utility:chevronup' : 'utility:chevrondown'; }

    toggleAntecedentes() { this.isAntecedenteOpen = !this.isAntecedenteOpen; }
    toggleDriverVisual() { this.isDriverVisualOpen = !this.isDriverVisualOpen; }
    togglePreguntasPoder() { this.isPreguntasPoderOpen = !this.isPreguntasPoderOpen; }
    toggleGraduaciones() { this.isGraduacionesOpen = !this.isGraduacionesOpen; }
    toggleFamilia() { this.isFamiliaOpen = !this.isFamiliaOpen; }

    toggleOrden(e) {
        const id = e.currentTarget.dataset.id;
        this.orders = this.orders.map(o => o.ordenId === id ? { ...o, isExpanded: !o.isExpanded, chevronIcon: !o.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', detailsClass: !o.isExpanded ? 'orden-details expanded' : 'orden-details collapsed' } : o);
    }

    toggleCotizacion(e) {
        const id = e.currentTarget.dataset.id;
        this.quotes = this.quotes.map(q => q.presupuestoId === id ? { ...q, isExpanded: !q.isExpanded, chevronIcon: !q.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', productosClass: !q.isExpanded ? 'cotizacion-productos expanded' : 'cotizacion-productos collapsed' } : q);
    }

    toggleCampana(e) {
        const id = e.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(c => c.nombre === id ? { ...c, isExpanded: !c.isExpanded, chevronIcon: !c.isExpanded ? 'utility:chevronup' : 'utility:chevrondown', detailsClass: !c.isExpanded ? 'campana-details expanded' : 'campana-details collapsed' } : c);
    }

    toggleEnvio(e) {
        const index = parseInt(e.currentTarget.dataset.index, 10);
        const campanaIdx = parseInt(e.currentTarget.dataset.campana, 10);
        let camps = JSON.parse(JSON.stringify(this.campaigns));
        let env = camps[campanaIdx].envios[index];
        env.isExpanded = !env.isExpanded;
        env.chevronIcon = env.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
        env.detailsClass = env.isExpanded ? 'envio-details expanded' : 'envio-details collapsed';
        this.campaigns = camps;
    }

    async handleRefresh() {
        this.isLoading = true;
        await refreshApex(this._wiredResult);
        this.isLoading = false;
    }
}