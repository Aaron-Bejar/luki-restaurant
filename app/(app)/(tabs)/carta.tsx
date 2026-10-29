import { useCallback, useEffect, useMemo, useState } from "react";
import { ActivityIndicator, Modal, Pressable, ScrollView, Text, TextInput, View } from "react-native";
import { type Href, useRouter } from "expo-router";

import { useSesion } from "@/auth/session-context";
import { filtrarPlatosPorCategoria, textoDisponibilidad } from "@/features/carta/presentacion";
import { actualizarPlato, crearPlato, establecerDisponibilidadPlato, listarCarta, listarCategorias } from "@/services/carta";
import type { Carta, Categoria } from "@/types/supabase";

type FormularioPlato = { categoriaId: number | null; nombre: string; precio: string };
const formularioVacio: FormularioPlato = { categoriaId: null, nombre: "", precio: "" };

export default function CartaScreen() {
  const { sesion, tokenSesion } = useSesion();
  const router = useRouter();
  const esOwner = sesion?.rol === "owner";
  const [categorias, setCategorias] = useState<Categoria[]>([]);
  const [platos, setPlatos] = useState<Carta[]>([]);
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState<number | null>(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [errorFormulario, setErrorFormulario] = useState<string | null>(null);
  const [modalPlato, setModalPlato] = useState(false);
  const [formulario, setFormulario] = useState<FormularioPlato>(formularioVacio);
  const [platoEditando, setPlatoEditando] = useState<Carta | null>(null);
  const [guardando, setGuardando] = useState(false);

  const cargar = useCallback(async () => {
    if (!tokenSesion) return;
    setCargando(true); setError(null);
    try {
      const [categoriasActuales, platosActuales] = await Promise.all([listarCategorias(tokenSesion), listarCarta(tokenSesion)]);
      setCategorias(categoriasActuales); setPlatos(platosActuales);
    } catch (cause) { setError(cause instanceof Error ? cause.message : "No se pudo cargar la carta."); }
    finally { setCargando(false); }
  }, [tokenSesion]);

  useEffect(() => { void cargar(); }, [cargar]);
  const platosFiltrados = useMemo(() => filtrarPlatosPorCategoria(platos, categoriaSeleccionada), [platos, categoriaSeleccionada]);

  function abrirNuevoPlato() {
    setPlatoEditando(null);
    setErrorFormulario(null);
    setFormulario({ ...formularioVacio, categoriaId: categorias[0]?.id ?? null });
    setModalPlato(true);
  }
  function abrirEdicion(plato: Carta) {
    setPlatoEditando(plato);
    setErrorFormulario(null);
    setFormulario({ categoriaId: plato.categoria_id, nombre: plato.nombre, precio: String(plato.precio) });
    setModalPlato(true);
  }
  async function guardarPlato() {
    const precio = Number(formulario.precio);
    if (!tokenSesion || !formulario.nombre.trim() || formulario.categoriaId === null || !Number.isFinite(precio) || precio < 0) {
      setErrorFormulario("Completa nombre, categoría y un precio válido.");
      return;
    }
    setGuardando(true); setErrorFormulario(null);
    try {
      if (platoEditando) await actualizarPlato(tokenSesion, platoEditando.id, { categoria_id: formulario.categoriaId, nombre: formulario.nombre, precio });
      else await crearPlato(tokenSesion, { categoria_id: formulario.categoriaId, nombre: formulario.nombre, precio });
      setModalPlato(false); await cargar();
    } catch (cause) { setErrorFormulario(cause instanceof Error ? cause.message : "No se pudo guardar el plato."); }
    finally { setGuardando(false); }
  }
  async function cambiarDisponibilidad(plato: Carta) {
    if (!tokenSesion) return;
    setError(null);
    try { await establecerDisponibilidadPlato(tokenSesion, plato.id, !plato.activo); await cargar(); }
    catch (cause) { setError(cause instanceof Error ? cause.message : "No se pudo actualizar la disponibilidad."); }
  }

  return <View className="flex-1 bg-[--color-surface] px-6 py-10">
    <Text className="text-3xl font-bold text-[--color-ink]">Carta</Text>
    {esOwner ?
      <View className="mt-5 flex-row flex-wrap gap-3">
        <Pressable onPress={abrirNuevoPlato} className="rounded-xl bg-[--color-primary] px-4 py-3">
          <Text className="font-semibold text-white">+ Producto</Text>
        </Pressable>
        <Pressable onPress={() => router.push("/(app)/categorias" as Href)} className="rounded-xl border border-[--color-primary] px-4 py-3">
          <Text className="font-semibold text-[--color-primary]">Gestionar categorías</Text>
        </Pressable>
      </View>
      : null}
    {error ? <Text accessibilityRole="alert" className="mt-3 text-[--color-danger]">{error}</Text> : null}
    {cargando ?
      <ActivityIndicator className="mt-10" color="#1eab64" />
      : <><View className="mt-6 h-12 justify-center">
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerClassName="items-center">
          <Chip activa={categoriaSeleccionada === null} etiqueta="Todas" onPress={() => setCategoriaSeleccionada(null)} />{categorias.map((categoria) => <Chip key={categoria.id} activa={categoriaSeleccionada === categoria.id} etiqueta={categoria.nombre} onPress={() => setCategoriaSeleccionada(categoria.id)} />)}
        </ScrollView>
      </View>
        <ScrollView className="mt-3 flex-1" contentContainerClassName="pb-10">{platosFiltrados.length === 0 ? <Text className="text-[--color-muted]">No hay platos en esta categoría.</Text> : platosFiltrados.map((plato) => <View key={plato.id} className="mb-3 rounded-2xl border border-[--color-line] bg-white p-4"><View className="flex-row items-start justify-between"><View className="flex-1"><Text className="text-lg font-semibold text-[--color-ink]">{plato.nombre}</Text><Text className="mt-1 text-base text-[--color-muted]">S/ {Number(plato.precio).toFixed(2)}</Text></View><Text className={plato.activo ? "text-[--color-primary]" : "text-[--color-danger]"}>{textoDisponibilidad(plato.activo)}</Text></View>{esOwner ? <View className="mt-3 flex-row gap-4"><Pressable onPress={() => abrirEdicion(plato)}><Text className="font-semibold text-[--color-primary]">Editar</Text></Pressable><Pressable onPress={() => void cambiarDisponibilidad(plato)}><Text className="font-semibold text-[--color-primary]">{plato.activo ? "Marcar no disponible" : "Activar"}</Text></Pressable></View> : null}</View>)}</ScrollView></>}
    <Modal visible={modalPlato} transparent animationType="fade" onRequestClose={() => setModalPlato(false)}>
      <ModalBox titulo={platoEditando ? "Editar producto" : "Nuevo producto"} onClose={() => setModalPlato(false)}>
        <TextInput value={formulario.nombre} onChangeText={(nombre) => setFormulario((actual) => ({ ...actual, nombre }))} placeholder="Nombre" className="rounded-xl border border-[--color-line] px-3 py-3" />
        <TextInput value={formulario.precio} onChangeText={(precio) => setFormulario((actual) => ({ ...actual, precio }))} placeholder="Precio" keyboardType="decimal-pad" className="mt-3 rounded-xl border border-[--color-line] px-3 py-3" />
        {errorFormulario ? <Text accessibilityRole="alert" className="mt-2 text-[--color-danger]">{errorFormulario}</Text> : null}
        <ScrollView horizontal className="mt-3 max-h-12">
          {categorias.map((categoria) => <Chip key={categoria.id} activa={formulario.categoriaId === categoria.id} etiqueta={categoria.nombre} onPress={() => setFormulario((actual) => ({ ...actual, categoriaId: categoria.id }))} />)}
        </ScrollView>
        <Accion disabled={guardando || categorias.length === 0} etiqueta={guardando ? "Guardando…" : "Guardar producto"} onPress={() => void guardarPlato()} />
      </ModalBox>
    </Modal>
  </View>;
}

function Chip({ activa, etiqueta, onPress }: { activa: boolean; etiqueta: string; onPress: () => void }) {
  return <>
    <Pressable onPress={onPress} className={`mr-2 h-10 items-center justify-center rounded-full px-4 ${activa ? "bg-[--color-primary]" : "border border-[--color-line] bg-white"}`}>
      <Text className={activa ? "font-semibold text-white" : "text-[--color-ink]"}>
        {etiqueta}
      </Text>
    </Pressable>
  </>;
}
function ModalBox({ children, onClose, titulo }: { children: React.ReactNode; onClose: () => void; titulo: string }) {
  return <>
    {/* Cambiado View por Pressable para detectar el clic en el fondo */}
    <Pressable className="flex-1 justify-end bg-black/30" onPress={onClose}>

      {/* Este Pressable vacío con onPress={() => {}} evita que el modal 
            se cierre si el usuario hace clic dentro del contenido blanco */}
      <Pressable className="rounded-t-3xl bg-[--color-surface] p-6" onPress={(e) => e.stopPropagation()}>
        <View className="mb-5 flex-row items-center justify-between">
          <Text className="text-xl font-bold text-[--color-ink]">{titulo}</Text>
          <Pressable onPress={onClose}>
            <Text className="text-[--color-primary]">Cerrar</Text>
          </Pressable>
        </View>
        {children}
      </Pressable>
    </Pressable>
  </>;
}

function Accion({ disabled, etiqueta, onPress }: { disabled: boolean; etiqueta: string; onPress: () => void }) {
  return <Pressable disabled={disabled} onPress={onPress} className="mt-5 items-center rounded-xl bg-[--color-primary] py-3 disabled:opacity-50"><Text className="font-semibold text-white">{etiqueta}</Text></Pressable>;
}
