import { supabase } from "@/lib/supabase";
import type { RolUsuario } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export type UsuarioOperativo = {
  activo: boolean;
  id: string;
  nombre: string;
  rol: RolUsuario;
};

export type SesionOperativa = {
  expira_en: string;
  nombre: string;
  rol: RolUsuario;
  token_sesion: string;
  usuario_id: string;
};

export async function iniciarTurno(nombre: string, pin: string): Promise<SesionOperativa> {
  const { data, error } = await supabase.rpc("iniciar_turno", {
    p_nombre: nombre,
    p_pin: pin,
  });

  const sesion = requireData(data, error)[0];

  if (!sesion) {
    throw new Error("El inicio de turno no devolvió una sesión.");
  }

  return sesion;
}

export async function cerrarTurno(tokenSesion: string): Promise<void> {
  const { error } = await supabase.rpc("cerrar_turno", {
    p_token_sesion: tokenSesion,
  });

  requireSuccess(error);
}
