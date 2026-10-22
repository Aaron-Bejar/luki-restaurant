import { supabase } from "@/lib/supabase";
import type { Mesa } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export async function listarMesas(tokenSesion: string): Promise<Mesa[]> {
  const { data, error } = await supabase.rpc("listar_mesas", { p_token_sesion: tokenSesion });

  return requireData(data, error);
}

export async function obtenerMesa(tokenSesion: string, id: number): Promise<Mesa> {
  const { data, error } = await supabase.rpc("obtener_mesa", { p_token_sesion: tokenSesion, p_mesa_id: id });

  return requireData(data, error);
}

export async function crearMesa(tokenSesion: string, numero: number): Promise<Mesa> {
  const { data, error } = await supabase.rpc("crear_mesa", { p_token_sesion: tokenSesion, p_numero: numero });

  return requireData(data, error);
}

export async function actualizarNumeroMesa(tokenSesion: string, id: number, numero: number): Promise<Mesa> {
  const { data, error } = await supabase.rpc("actualizar_numero_mesa", { p_token_sesion: tokenSesion, p_mesa_id: id, p_numero: numero });

  return requireData(data, error);
}

export async function eliminarMesa(tokenSesion: string, id: number): Promise<void> {
  const { error } = await supabase.rpc("eliminar_mesa", { p_token_sesion: tokenSesion, p_mesa_id: id });

  requireSuccess(error);
}
