/// Responsabilidad: Convertir los campos del formulario en el comando de
/// insertar o actualizar de equipos_control. Un texto vacio se guarda nulo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/campo_escritura.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/formulario/equipos_formulario_campos.dart';

class EquipoFormularioComandoTransformador {
  static EquiposControlInsertar insertar(EquiposFormularioCampos campos) =>
      EquiposControlInsertar(
        // La validacion ya exigio la empresa.
        fkEmpresa: campos.empresa!.id,
        fkSede: campos.sede?.id,
        nombre: _texto(campos.nombreControlador.text),
        ubicacion: null,
        idEquipoFabrica: _texto(campos.idFabricaControlador.text),
        tipoEquipoControl: _texto(campos.tipoControlador.text),
        codigoEquipoControl: _texto(campos.codigoControlador.text),
        direccionMac: _texto(campos.direccionMacControlador.text),
        observaciones: _texto(campos.observacionesControlador.text),
        fkAreaAsociada: null,
        fkEquipoAsociado: null,
        fechaInicio: campos.fechaInicio,
        fechaFinal: null,
      );

  static EquiposControlActualizar actualizar(EquiposFormularioCampos campos) =>
      EquiposControlActualizar(
        fkEmpresa: CampoEscritura.valor(campos.empresa!.id),
        fkSede: CampoEscritura.valor(campos.sede?.id),
        nombre: CampoEscritura.valor(_texto(campos.nombreControlador.text)),
        idEquipoFabrica: CampoEscritura.valor(
          _texto(campos.idFabricaControlador.text),
        ),
        tipoEquipoControl: CampoEscritura.valor(
          _texto(campos.tipoControlador.text),
        ),
        codigoEquipoControl: CampoEscritura.valor(
          _texto(campos.codigoControlador.text),
        ),
        direccionMac: CampoEscritura.valor(
          _texto(campos.direccionMacControlador.text),
        ),
        observaciones: CampoEscritura.valor(
          _texto(campos.observacionesControlador.text),
        ),
        fechaInicio: CampoEscritura.valor(campos.fechaInicio),
      );

  static String? _texto(String valor) {
    final limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }
}
