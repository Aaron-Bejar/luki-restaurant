export type DependenciasCierreTurno = {
  eliminarToken: () => Promise<void>;
  revocarTurno: (tokenSesion: string) => Promise<void>;
};

/**
 * Revoca primero la sesión en el servidor y solo después elimina su copia
 * local. Si la revocación no se confirma, el turno se conserva para poder
 * reintentar sin presentar un cierre que no ocurrió.
 */
export async function cerrarTurnoSeguro(
  tokenSesion: string | null,
  { eliminarToken, revocarTurno }: DependenciasCierreTurno,
): Promise<void> {
  if (tokenSesion) await revocarTurno(tokenSesion);
  await eliminarToken();
}
