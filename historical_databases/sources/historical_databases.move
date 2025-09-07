module historical_databases::historical_databases {
    use std::string::{String, utf8};
    use sui::vec_map::{VecMap, Self as vec_map};
  
    public struct Clinica has key, store {
        id:UID,
        nombre:String,
        pacientes: VecMap<u64, Paciente>

    }

    public struct Paciente has store, drop {
        id_paciente: u64,
        nombre: String,
        historial: VecMap<u64, Consulta>,
        prox_id_consulta: u64
    }

    public struct Consulta has store, drop {
        consulta_id: u64,
        fecha: String,
        medico: String,
        diagnostico: String, 
        tratamiento: String, 
        notas: String,
        estado: String,
    }

    #[error]
    const YA_EXISTE_PACIENTE: vector<u8> = b"Ya existe el paciente, intente con otro";
    #[error]
    const NO_EXISTE_PACIENTE: u16 = 404;
    #[error]
    const CONSULTA_NO_ENCONTRADA: u16 = 404;
    #[error]
    const CONSULTA_CERRADA:vector<u8> = b"Consulta cerrada, intente con otro";

    public fun crear_clinica(nombre: String, ctx: &mut TxContext) {
        let clinica = Clinica {
            id: object::new(ctx),
            nombre,
            pacientes: vec_map::empty(),
        };
        transfer::transfer(clinica, tx_context::sender(ctx));
    }

    public fun registrar_paciente(clinica: &mut Clinica, id_paciente: u64, nombre: String) {
        assert!(clinica.pacientes.contains(&id_paciente), YA_EXISTE_PACIENTE);
        let paciente = Paciente {
            id_paciente,
            nombre, 
            historial: vec_map::empty(),
            prox_id_consulta: 0,
        };
        clinica.pacientes.insert(id_paciente, paciente);
    }

    public fun eliminar_paciente(clinica: &mut Clinica, id_paciente: u64) {
        assert!(clinica.pacientes.contains(&id_paciente), NO_EXISTE_PACIENTE);
        clinica.pacientes.remove(&id_paciente);
    }

    public fun agregar_consulta(clinica: &mut Clinica, id_paciente:u64, fecha: String, medico: String, diagnostico: String, tratamiento: String, notas: String) {
        assert!(clinica.pacientes.contains(&id_paciente), NO_EXISTE_PACIENTE);
        let paciente = clinica.pacientes.get_mut(&id_paciente);
        let consulta_id = paciente.prox_id_consulta;

        assert!(!paciente.historial.contains(&consulta_id), CONSULTA_NO_ENCONTRADA);

        let consulta = Consulta {
            consulta_id,
            fecha,
            medico,
            diagnostico,
            tratamiento,
            notas,
            estado: utf8(b"Abierta"),
        };

        paciente.historial.insert(consulta_id, consulta);
        paciente.prox_id_consulta = consulta_id + 1;
    }

    public fun actualizar_consulta(
        clinica: &mut Clinica, 
        id_paciente: u64, 
        consulta_id: u64,
        nuevo_diagnostico: String,
        nuevo_tratamiento: String,
        nuevas_notas: String){
            assert!(clinica.pacientes.contains(&id_paciente), NO_EXISTE_PACIENTE);
            let paciente = clinica.pacientes.get_mut(&id_paciente);
            assert!(paciente.historial.contains(&consulta_id), CONSULTA_NO_ENCONTRADA);
            let consulta = paciente.historial.get_mut(&consulta_id);
            assert!(consulta.estado == utf8(b"Abierta"), CONSULTA_CERRADA);

            consulta.diagnostico = nuevo_diagnostico;
            consulta.tratamiento = nuevo_tratamiento;
            consulta.notas = nuevas_notas;
        }

        public fun cerrar_consulta(
            clinica: &mut Clinica,
            id_paciente: u64,
            consulta_id: u64,
            observaciones: String
        ) {
            assert!(clinica.pacientes.contains(&id_paciente), NO_EXISTE_PACIENTE);
            let paciente = clinica.pacientes.get_mut(&id_paciente);
            assert!(paciente.historial.contains(&consulta_id), CONSULTA_NO_ENCONTRADA);
            let consulta = paciente.historial.get_mut(&consulta_id);
            assert!(consulta.estado == utf8(b"Abierta"), CONSULTA_CERRADA);

            consulta.notas = observaciones;
            consulta.estado = utf8(b"Cerrada");
        }

        public fun borrar_consulta(
            clinica: &mut Clinica,
            id_paciente: u64,
            consulta_id: u64
            ){
            assert!(clinica.pacientes.contains(&id_paciente), NO_EXISTE_PACIENTE);
            let paciente = clinica.pacientes.get_mut(&id_paciente);
            assert!(paciente.historial.contains(&consulta_id), CONSULTA_NO_ENCONTRADA);
            paciente.historial.remove(&consulta_id);
            }
}





