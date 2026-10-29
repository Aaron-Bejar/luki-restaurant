import { supabase } from "@/lib/supabase";
import type { Carta, Categoria } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export type CrearPlatoInput = Pick<Carta, "categoria_id" | "nombre" | "precio">;
export type ActualizarPlatoInput = Partial<CrearPlatoInput & Pick<Carta, "activo">>;
export type CrearCategoriaInput = Pick<Categoria, "nombre">;

export async function listarCarta(tokenSesion: string): Promise<Carta[]> {
  const { data, error } = await supabase.rpc("listar_carta", { p_token_sesion: tokenSesion });

  return requireData(data, error);
}

export async function listarCategorias(tokenSesion: string): Promise<Categoria[]> {
  const { data, error } = await supabase.rpc("listar_categorias", { p_token_sesion: tokenSesion });

  return requireData(data, error);
}

export async function crearCategoria(tokenSesion: string, input: CrearCategoriaInput): Promise<Categoria> {
  const { data, error } = await supabase.rpc("crear_categoria", { p_nombre: input.nombre, p_token_sesion: tokenSesion });
  return requireData(data, error);
}

export async function actualizarCategoria(tokenSesion: string, id: number, nombre: string): Promise<Categoria> {
  const { data, error } = await supabase.rpc("actualizar_categoria", { p_categoria_id: id, p_nombre: nombre, p_token_sesion: tokenSesion });
  return requireData(data, error);
}

export async function eliminarCategoria(tokenSesion: string, id: number): Promise<void> {
  const { error } = await supabase.rpc("eliminar_categoria", { p_categoria_id: id, p_token_sesion: tokenSesion });
  requireSuccess(error);
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
  const { error } = await supabase.rpc("establecer_disponibilidad_plato", { p_token_sesion: tokenSesion, p_plato_id: id, p_activo: false });

  requireSuccess(error);
}

export async function establecerDisponibilidadPlato(tokenSesion: string, id: number, activo: boolean): Promise<Carta> {
  const { data, error } = await supabase.rpc("establecer_disponibilidad_plato", { p_token_sesion: tokenSesion, p_plato_id: id, p_activo: activo });
  return requireData(data, error);
}
