// Generado a partir del esquema de Luki-restaurant el 2026-10-21.
// Se regenera con: npm run types:gen

export type Database = {
  public: {
    Tables: {
      carta: {
        Row: {
          activo: boolean;
          categoria_id: number;
          created_at: string;
          id: number;
          nombre: string;
          precio: number;
          updated_at: string;
        };
        Insert: {
          activo?: boolean;
          categoria_id: number;
          created_at?: string;
          id?: number;
          nombre: string;
          precio: number;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["carta"]["Insert"]>;
        Relationships: [];
      };
      categoria: {
        Row: {
          activo: boolean;
          created_at: string;
          id: number;
          nombre: string;
          updated_at: string;
        };
        Insert: {
          activo?: boolean;
          created_at?: string;
          id?: number;
          nombre: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["categoria"]["Insert"]>;
        Relationships: [];
      };
      detalle_pedido: {
        Row: {
          cantidad: number;
          carta_id: number;
          created_at: string;
          estado_item: EstadoItem;
          id: number;
          nombre_plato: string;
          num_persona: number;
          pedido_id: number;
          precio_unitario: number;
          updated_at: string;
        };
        Insert: {
          cantidad?: number;
          carta_id: number;
          created_at?: string;
          estado_item?: EstadoItem;
          id?: number;
          nombre_plato: string;
          num_persona: number;
          pedido_id: number;
          precio_unitario: number;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["detalle_pedido"]["Insert"]>;
        Relationships: [];
      };
      mesas: {
        Row: {
          created_at: string;
          estado: EstadoMesa;
          id: number;
          numero: number;
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          estado?: EstadoMesa;
          id?: number;
          numero: number;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["mesas"]["Insert"]>;
        Relationships: [];
      };
      pedido: {
        Row: Pedido;
        Insert: {
          abierto_en?: string;
          abierto_por_usuario_id: string;
          cerrado_en?: string | null;
          created_at?: string;
          estado?: EstadoPedido;
          id?: number;
          mesa_id: number;
          metodo_pago?: MetodoPago | null;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["pedido"]["Insert"]>;
        Relationships: [];
      };
      sesion_operativa: {
        Row: {
          creada_en: string;
          expira_en: string;
          id: string;
          revocada_en: string | null;
          token_hash: string;
          usuario_id: string;
        };
        Insert: {
          creada_en?: string;
          expira_en: string;
          id?: string;
          revocada_en?: string | null;
          token_hash: string;
          usuario_id: string;
        };
        Update: Partial<Database["public"]["Tables"]["sesion_operativa"]["Insert"]>;
        Relationships: [];
      };
      usuario: {
        Row: Usuario;
        Insert: {
          activo?: boolean;
          created_at?: string;
          id?: string;
          nombre: string;
          pin_hash: string;
          rol: RolUsuario;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["usuario"]["Insert"]>;
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: {
      abrir_mesa: {
        Args: { p_mesa_id: number; p_token_sesion: string };
        Returns: Pedido;
      };
      cerrar_pedido: {
        Args: {
          p_metodo_pago: MetodoPago;
          p_pedido_id: number;
          p_token_sesion: string;
        };
        Returns: Pedido;
      };
      cerrar_turno: {
        Args: { p_token_sesion: string };
        Returns: undefined;
      };
      iniciar_turno: {
        Args: { p_nombre: string; p_pin: string };
        Returns: {
          expira_en: string;
          nombre: string;
          rol: RolUsuario;
          token_sesion: string;
          usuario_id: string;
        }[];
      };
      obtener_pedido_activo_por_mesa: { Args: { p_mesa_id: number; p_token_sesion: string }; Returns: Pedido[] };
      listar_detalle_pedido: { Args: { p_pedido_id: number; p_token_sesion: string }; Returns: DetallePedido[] };
      agregar_detalle_pedido: { Args: { p_cantidad: number; p_carta_id: number; p_num_persona: number; p_pedido_id: number; p_token_sesion: string }; Returns: DetallePedido };
      actualizar_detalle_pedido: { Args: { p_cantidad: number; p_detalle_id: number; p_estado_item: EstadoItem; p_token_sesion: string }; Returns: DetallePedido };
      listar_mesas: { Args: { p_token_sesion: string }; Returns: Mesa[] };
      obtener_mesa: { Args: { p_mesa_id: number; p_token_sesion: string }; Returns: Mesa };
      crear_mesa: { Args: { p_numero: number; p_token_sesion: string }; Returns: Mesa };
      actualizar_numero_mesa: { Args: { p_mesa_id: number; p_numero: number; p_token_sesion: string }; Returns: Mesa };
      eliminar_mesa: { Args: { p_mesa_id: number; p_token_sesion: string }; Returns: undefined };
      listar_carta_activa: { Args: { p_token_sesion: string }; Returns: Carta[] };
      listar_categorias_activas: { Args: { p_token_sesion: string }; Returns: Categoria[] };
      crear_plato: { Args: { p_categoria_id: number; p_nombre: string; p_precio: number; p_token_sesion: string }; Returns: Carta };
      actualizar_plato: { Args: { p_activo?: boolean | null; p_categoria_id?: number | null; p_nombre?: string | null; p_plato_id: number; p_precio?: number | null; p_token_sesion: string }; Returns: Carta };
      desactivar_plato: { Args: { p_plato_id: number; p_token_sesion: string }; Returns: undefined };
    };
    Enums: {
      estado_item: EstadoItem;
      estado_mesa: EstadoMesa;
      estado_pedido: EstadoPedido;
      metodo_pago: MetodoPago;
      rol_usuario: RolUsuario;
    };
    CompositeTypes: Record<string, never>;
  };
};

export type EstadoItem = "pendiente" | "en_cocina" | "entregado" | "cancelado";
export type EstadoMesa = "libre" | "ocupada";
export type EstadoPedido = "activo" | "pagado";
export type MetodoPago = "efectivo" | "tarjeta" | "billetera_digital";
export type RolUsuario = "owner" | "waitress";

export type Pedido = {
  abierto_en: string;
  abierto_por_usuario_id: string;
  cerrado_en: string | null;
  created_at: string;
  estado: EstadoPedido;
  id: number;
  mesa_id: number;
  metodo_pago: MetodoPago | null;
  updated_at: string;
};

export type Usuario = {
  activo: boolean;
  created_at: string;
  id: string;
  nombre: string;
  pin_hash: string;
  rol: RolUsuario;
  updated_at: string;
};

export type Mesa = Database["public"]["Tables"]["mesas"]["Row"];
export type Categoria = Database["public"]["Tables"]["categoria"]["Row"];
export type Carta = Database["public"]["Tables"]["carta"]["Row"];
export type DetallePedido = Database["public"]["Tables"]["detalle_pedido"]["Row"];
