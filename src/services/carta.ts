import { supabase } from "@/lib/supabase";
import type { Carta, Categoria } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export type CrearPlatoInput = Pick<Carta, "categoria_id" | "nombre" | "precio">;
export type ActualizarPlatoInput = Partial<CrearPlatoInput & Pick<Carta, "activo">>;

export async function listarCartaActiva(tokenSesion: string): Promise<Carta[]> {
  const { data, error } = await supabase.rpc("listar_carta_activa", { p_token_sesion: tokenSesion });

  return requireData(data, error);
}

export async function listarCategoriasActivas(tokenSesion: string): Promise<Categoria[]> {
  const { data, error } = await supabase.rpc("listar_categorias_activas", { p_token_sesion: tokenSesion });

  return requireData(data, error);
}

export async function crearPlato(tokenSesion: string, input: CrearPlatoInput): Promise<Carta> {
  const { data, error } = await supabase.rpc("crear_plato", { p_token_sesion: tokenSesion, p_categoria_id: input.categoria_id, p_nombre: input.nombre, p_precio: input.precio });

  return requireData(data, error);
}

export async function actualizarPlato(tokenSesion: string, id: number, input: ActualizarPlatoInput): Promise<Carta> {
  const { data, error } = await supabase.rpc("actualizar_plato", { p_token_sesion: tokenSesion, p_plato_id: id, p_categoria_id: input.categoria_id ?? null, p_nombre: input.nombre ?? null, p_precio: input.precio ?? null, p_activo: input.activo ?? null });

  return requireData(data, error);
}

export async function desactivarPlato(tokenSesion: string, id: number): Promise<void> {
  const { error } = await supabase.rpc("desactivar_plato", { p_token_sesion: tokenSesion, p_plato_id: id });

  requireSuccess(error);
}
