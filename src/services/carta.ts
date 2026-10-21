import { supabase } from "@/lib/supabase";
import type { Carta, Categoria } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export type CrearPlatoInput = Pick<Carta, "categoria_id" | "nombre" | "precio">;
export type ActualizarPlatoInput = Partial<CrearPlatoInput & Pick<Carta, "activo">>;

export async function listarCartaActiva(): Promise<Carta[]> {
  const { data, error } = await supabase
    .from("carta")
    .select("*")
    .eq("activo", true)
    .order("nombre");

  return requireData(data, error);
}

export async function listarCategoriasActivas(): Promise<Categoria[]> {
  const { data, error } = await supabase
    .from("categoria")
    .select("*")
    .eq("activo", true)
    .order("nombre");

  return requireData(data, error);
}

export async function crearPlato(input: CrearPlatoInput): Promise<Carta> {
  const { data, error } = await supabase.from("carta").insert(input).select().single();

  return requireData(data, error);
}

export async function actualizarPlato(id: number, input: ActualizarPlatoInput): Promise<Carta> {
  const { data, error } = await supabase
    .from("carta")
    .update(input)
    .eq("id", id)
    .select()
    .single();

  return requireData(data, error);
}

export async function desactivarPlato(id: number): Promise<void> {
  const { error } = await supabase.from("carta").update({ activo: false }).eq("id", id);

  requireSuccess(error);
}
