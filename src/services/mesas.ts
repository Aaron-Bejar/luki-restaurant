import { supabase } from "@/lib/supabase";
import type { Mesa } from "@/types/supabase";

import { requireData, requireSuccess } from "./query";

export async function listarMesas(): Promise<Mesa[]> {
  const { data, error } = await supabase.from("mesas").select("*").order("numero");

  return requireData(data, error);
}

export async function obtenerMesa(id: number): Promise<Mesa> {
  const { data, error } = await supabase.from("mesas").select("*").eq("id", id).single();

  return requireData(data, error);
}

export async function crearMesa(numero: number): Promise<Mesa> {
  const { data, error } = await supabase.from("mesas").insert({ numero }).select().single();

  return requireData(data, error);
}

export async function actualizarNumeroMesa(id: number, numero: number): Promise<Mesa> {
  const { data, error } = await supabase
    .from("mesas")
    .update({ numero })
    .eq("id", id)
    .select()
    .single();

  return requireData(data, error);
}

export async function eliminarMesa(id: number): Promise<void> {
  const { error } = await supabase.from("mesas").delete().eq("id", id);

  requireSuccess(error);
}
