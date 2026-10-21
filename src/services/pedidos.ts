import { supabase } from "@/lib/supabase";
import type { DetallePedido, EstadoItem, MetodoPago, Pedido } from "@/types/supabase";

import { requireData } from "./query";

export type CrearDetallePedidoInput = Pick<
  DetallePedido,
  "carta_id" | "cantidad" | "nombre_plato" | "num_persona" | "pedido_id" | "precio_unitario"
>;

export type ActualizarDetallePedidoInput = Pick<DetallePedido, "cantidad" | "estado_item">;

export async function abrirMesa(mesaId: number, usuarioId: string): Promise<Pedido> {
  const { data, error } = await supabase.rpc("abrir_mesa", {
    p_mesa_id: mesaId,
    p_usuario_id: usuarioId,
  });

  return requireData(data, error);
}

export async function cerrarPedido(
  pedidoId: number,
  usuarioId: string,
  metodoPago: MetodoPago,
): Promise<Pedido> {
  const { data, error } = await supabase.rpc("cerrar_pedido", {
    p_pedido_id: pedidoId,
    p_usuario_id: usuarioId,
    p_metodo_pago: metodoPago,
  });

  return requireData(data, error);
}

export async function obtenerPedidoActivoPorMesa(mesaId: number): Promise<Pedido | null> {
  const { data, error } = await supabase
    .from("pedido")
    .select("*")
    .eq("mesa_id", mesaId)
    .eq("estado", "activo")
    .maybeSingle();

  if (error) {
    throw new Error(error.message);
  }

  return data;
}

export async function listarDetallePedido(pedidoId: number): Promise<DetallePedido[]> {
  const { data, error } = await supabase
    .from("detalle_pedido")
    .select("*")
    .eq("pedido_id", pedidoId)
    .order("num_persona")
    .order("id");

  return requireData(data, error);
}

export async function agregarDetallePedido(
  input: CrearDetallePedidoInput,
): Promise<DetallePedido> {
  const { data, error } = await supabase
    .from("detalle_pedido")
    .insert(input)
    .select()
    .single();

  return requireData(data, error);
}

export async function actualizarDetallePedido(
  id: number,
  input: ActualizarDetallePedidoInput,
): Promise<DetallePedido> {
  const { data, error } = await supabase
    .from("detalle_pedido")
    .update(input)
    .eq("id", id)
    .select()
    .single();

  return requireData(data, error);
}

export async function cancelarDetallePedido(id: number): Promise<DetallePedido> {
  return actualizarDetallePedido(id, { cantidad: 0, estado_item: "cancelado" as EstadoItem });
}
