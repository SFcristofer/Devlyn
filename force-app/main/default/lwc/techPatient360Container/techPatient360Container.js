import { LightningElement, track } from 'lwc';

export default class TechPatient360Container extends LightningElement {
    @track selectedUnifiedId;

    handleProfileSelect(event) {
        // Al seleccionar un perfil en el buscador, actualizamos el ID
        // Esto provocará que el componente de abajo se recargue con los datos de esa persona
        this.selectedUnifiedId = event.detail.unifiedId;
        console.log('Unified ID Selected in Container:', this.selectedUnifiedId);
    }
}