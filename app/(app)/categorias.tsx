import { useCallback, useEffect, useState } from "react";
import { ActivityIndicator, FlatList, Modal, Pressable, Text, TextInput, View } from "react-native";
import { Redirect, type Href, useRouter } from "expo-router";

import { useSesion } from "@/auth/session-context";
import { actualizarCategoria, crearCategoria, eliminarCategoria, listarCategorias } from "@/services/carta";
import type { Categoria } from "@/types/supabase";

export default function CategoriasScreen() {
  const { sesion, tokenSesion } = useSesion();
  const router = useRouter();
  const [categorias, setCategorias] = useState<Categoria[]>([]);
  const [nombre, setNombre] = useState("");
  const [editando, setEditando] = useState<Categoria | null>(null);
  const [cargando, setCargando] = useState(true);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [errorFormulario, setErrorFormulario] = useState<string | null>(null);
  const [categoriaAEliminar, setCategoriaAEliminar] = useState<Categoria | null>(null);

  const cargar = useCallback(async () => {
    if (!tokenSesion || sesion?.rol !== "owner") return;
    setCargando(true);
    setError(null);
    try { setCategorias(await listarCategorias(tokenSesion)); }
    catch (cause) { setError(cause instanceof Error ? cause.message : "No se pudieron cargar las categorías."); }
    finally { setCargando(false); }
  }, [sesion?.rol, tokenSesion]);

  useEffect(() => { void cargar(); }, [cargar]);
  if (sesion?.rol !== "owner") return <Redirect href={"/(app)/(tabs)/carta" as Href} />;

  async function guardar() {
    if (!tokenSesion || !nombre.trim()) {
      setErrorFormulario("Ingresa un nombre para la categoría.");
      return;
    }
    setGuardando(true); setErrorFormulario(null);
    try {
      if (editando) await actualizarCategoria(tokenSesion, editando.id, nombre);
      else await crearCategoria(tokenSesion, { nombre });
      setNombre(""); setEditando(null); await cargar();
    } catch (cause) { setErrorFormulario(cause instanceof Error ? cause.message : "No se pudo guardar la categoría."); }
    finally { setGuardando(false); }
  }

  function confirmarEliminacion(categoria: Categoria) {
    setCategoriaAEliminar(categoria);
  }
  async function borrar(id: number) {
    if (!tokenSesion) return;
    setError(null);
    try { await eliminarCategoria(tokenSesion, id); if (editando?.id === id) { setEditando(null); setNombre(""); } await cargar(); }
    catch (cause) { setError(cause instanceof Error ? cause.message : "No se pudo eliminar la categoría."); }
  }

  return <View className="flex-1 bg-[--color-surface] px-6 py-10">
    <Pressable accessibilityRole="button" onPress={() => router.replace("/(app)/(tabs)/carta" as Href)}><Text className="text-base text-[--color-primary]">‹ Volver a Carta</Text></Pressable>
    <Text className="mt-4 text-3xl font-bold text-[--color-ink]">Categorías</Text>
    <View className="mt-5 rounded-2xl border border-[--color-line] bg-white p-4"><Text className="mb-2 font-semibold text-[--color-ink]">{editando ? "Editar categoría" : "Nueva categoría"}</Text><TextInput value={nombre} onChangeText={setNombre} placeholder="Nombre" className="rounded-xl border border-[--color-line] px-3 py-3 text-base" />{errorFormulario ? <Text accessibilityRole="alert" className="mt-2 text-[--color-danger]">{errorFormulario}</Text> : null}<View className="mt-3 flex-row gap-3">{editando ? <Pressable onPress={() => { setEditando(null); setNombre(""); setErrorFormulario(null); }} className="rounded-xl border border-[--color-line] px-4 py-3"><Text>Cancelar</Text></Pressable> : null}<Pressable disabled={guardando} onPress={() => void guardar()} className="rounded-xl bg-[--color-primary] px-4 py-3"><Text className="font-semibold text-white">{guardando ? "Guardando…" : "Guardar"}</Text></Pressable></View></View>
    {error ? <Text accessibilityRole="alert" className="mt-3 text-[--color-danger]">{error}</Text> : null}
    {cargando ? <ActivityIndicator className="mt-8" color="#1eab64" /> : <FlatList className="mt-5" data={categorias} keyExtractor={(categoria) => String(categoria.id)} ListEmptyComponent={<Text className="text-[--color-muted]">Aún no hay categorías.</Text>} renderItem={({ item }) => <View className="mb-3 rounded-2xl border border-[--color-line] bg-white p-4"><Text className="text-lg font-semibold text-[--color-ink]">{item.nombre}</Text><View className="mt-3 flex-row gap-4"><Pressable onPress={() => { setEditando(item); setNombre(item.nombre); }}><Text className="font-semibold text-[--color-primary]">Editar</Text></Pressable><Pressable onPress={() => confirmarEliminacion(item)}><Text className="font-semibold text-[--color-danger]">Eliminar</Text></Pressable></View></View>} />}
    <Modal visible={categoriaAEliminar !== null} transparent animationType="fade" onRequestClose={() => setCategoriaAEliminar(null)}>
      <View className="flex-1 items-center justify-center bg-black/30 px-6">
        <View className="w-full max-w-sm rounded-3xl bg-white p-6">
          <Text className="text-xl font-bold text-[--color-ink]">Eliminar categoría</Text>
          <Text className="mt-3 text-base text-[--color-muted]">
            También se eliminarán los platos de “{categoriaAEliminar?.nombre}”. Los pedidos históricos conservarán su nombre y precio.
          </Text>
          <View className="mt-6 flex-row justify-end gap-3">
            <Pressable onPress={() => setCategoriaAEliminar(null)} className="rounded-xl border border-[--color-line] px-4 py-3"><Text className="font-semibold text-[--color-ink]">Cancelar</Text></Pressable>
            <Pressable onPress={() => { if (categoriaAEliminar) void borrar(categoriaAEliminar.id); setCategoriaAEliminar(null); }} className="rounded-xl bg-[--color-danger] px-4 py-3"><Text className="font-semibold text-white">Eliminar</Text></Pressable>

          </View>
        </View>
      </View>
    </Modal>
  </View>;
}
