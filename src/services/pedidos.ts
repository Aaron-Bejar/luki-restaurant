import { supabase } from "@/lib/supabase";
import type { DetallePedido, EstadoItem, MetodoPago, Pedido } from "@/types/supabase";

import { requireData } from "./query";

export type CrearDetallePedidoInput = Pick<DetallePedido, "cantidad" | "num_persona" | "pedido_id"> & {
  carta_id: number;
};

export type ActualizarDetallePedidoInput = Pick<DetallePedido, "cantidad" | "estado_item">;

export async function abrirMesa(mesaId: number, tokenSesion: string): Promise<Pedido> {
  const { data, error } = await supabase.rpc("abrir_mesa", {
    p_mesa_id: mesaId,
    p_token_sesion: tokenSesion,
  });

  return requireData(data, error);
}

export async function cerrarPedido(
  pedidoId: number,
  tokenSesion: string,
  metodoPago: MetodoPago,
): Promise<Pedido> {
  const { data, error } = await supabase.rpc("cerrar_pedido", {
    p_pedido_id: pedidoId,
    p_token_sesion: tokenSesion,
    p_metodo_pago: metodoPago,
  });

  return requireData(data, error);
}

export async function obtenerPedidoActivoPorMesa(tokenSesion: string, mesaId: number): Promise<Pedido | null> {
  const { data, error } = await supabase.rpc("obtener_pedido_activo_por_mesa", { p_token_sesion: tokenSesion, p_mesa_id: mesaId });

  if (error) {
    throw new Error(error.message);
  }

  return data?.[0] ?? null;
}

export async function listarDetallePedido(tokenSesion: string, pedidoId: number): Promise<DetallePedido[]> {
  const { data, error } = await supabase.rpc("listar_detalle_pedido", { p_token_sesion: tokenSesion, p_pedido_id: pedidoId });

  return requireData(data, error);
}

export async function agregarDetallePedido(tokenSesion: string, input: CrearDetallePedidoInput,
): Promise<DetallePedido> {
  const { data, error } = await supabase.rpc("agregar_detalle_pedido", { p_token_sesion: tokenSesion, p_pedido_id: input.pedido_id, p_carta_id: input.carta_id, p_num_persona: input.num_persona, p_cantidad: input.cantidad });

  return requireData(data, error);
}

export async function actualizarDetallePedido(tokenSesion: string, id: number,
  input: ActualizarDetallePedidoInput,
): Promise<DetallePedido> {
  const { data, error } = await supabase.rpc("actualizar_detalle_pedido", { p_token_sesion: tokenSesion, p_detalle_id: id, p_cantidad: input.cantidad, p_estado_item: input.estado_item });

  return requireData(data, error);
}

export async function cancelarDetallePedido(tokenSesion: string, id: number): Promise<DetallePedido> {
  return actualizarDetallePedido(tokenSesion, id, { cantidad: 0, estado_item: "cancelado" as EstadoItem });
}
