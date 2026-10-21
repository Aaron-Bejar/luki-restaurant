import { supabase } from "@/lib/supabase";
import type { RolUsuario } from "@/types/supabase";

import { requireData } from "./query";

export type UsuarioOperativo = {
  activo: boolean;
  id: string;
  nombre: string;
  rol: RolUsuario;
};

const usuarioOperativoColumns = "id,nombre,rol,activo";

export async function obtenerUsuarioOperativo(id: string): Promise<UsuarioOperativo> {
  const { data, error } = await supabase
    .from("usuario")
    .select(usuarioOperativoColumns)
    .eq("id", id)
    .single();

  return requireData(data, error);
}

export async function buscarUsuarioActivoPorNombre(
  nombre: string,
): Promise<UsuarioOperativo | null> {
  const { data, error } = await supabase
    .from("usuario")
    .select(usuarioOperativoColumns)
    .ilike("nombre", nombre.trim())
    .eq("activo", true)
    .maybeSingle();

  if (error) {
    throw new Error(error.message);
  }

  return data;
}
