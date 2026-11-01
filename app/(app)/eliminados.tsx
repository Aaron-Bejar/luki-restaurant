import { useCallback, useEffect, useState } from "react";
import { Redirect, type Href, useRouter } from "expo-router";
import { ActivityIndicator, Pressable, ScrollView, Text, View } from "react-native";
import { Image } from "expo-image";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useSesion } from "@/auth/session-context";
import { listarCategoriasEliminadas, listarPlatosEliminados, restaurarCategoria, restaurarPlato } from "@/services/carta";
import type { Carta, Categoria } from "@/types/supabase";

export default function EliminadosScreen() {
  const { sesion, tokenSesion } = useSesion();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [categorias, setCategorias] = useState<Categoria[]>([]);
  const [platos, setPlatos] = useState<Carta[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(true);
  const cargar = useCallback(async () => {
    if (!tokenSesion || sesion?.rol !== "owner") return;
    setCargando(true);
    try { const [c, p] = await Promise.all([listarCategoriasEliminadas(tokenSesion), listarPlatosEliminados(tokenSesion)]); setCategorias(c); setPlatos(p); setError(null); }
    catch (e) { setError(e instanceof Error ? e.message : "No se pudieron cargar los eliminados."); }
    finally { setCargando(false); }
  }, [tokenSesion, sesion?.rol]);
  useEffect(() => { void cargar(); }, [cargar]);
  if (sesion?.rol !== "owner") return <Redirect href={"/(app)/(tabs)/carta" as Href} />;
  async function restaurar(tipo: "categoria" | "plato", id: number) {
    if (!tokenSesion) return;
    try { if (tipo === "categoria") await restaurarCategoria(tokenSesion, id); else await restaurarPlato(tokenSesion, id); await cargar(); }
    catch (e) { setError(e instanceof Error ? e.message : "No se pudo restaurar."); }
  }
  return <View className="flex-1 bg-[--color-surface] px-6 pb-10" style={{ paddingTop: insets.top +16 }}>
    <Pressable accessibilityRole="button" accessibilityLabel="Volver a Carta" onPress={() => router.replace("/(app)/(tabs)/carta" as Href)} className="h-11 w-11 items-center justify-center"><Image source={require("../../assets/icons/volver.svg")} style={{ width: 22, height: 22 }} tintColor="#1eab64" /></Pressable>
    <Text className="mt-4 text-3xl font-bold">Eliminados</Text>
    {error ? <Text accessibilityRole="alert" className="mt-3 text-[--color-danger]">{error}</Text> : null}
    {cargando ? <ActivityIndicator /> : <ScrollView className="mt-5">
      <Text className="mb-3 text-xl font-semibold">Categorías</Text>
      {categorias.length === 0 ? <Text>No hay categorías eliminadas.</Text> : categorias.map(c => <View key={c.id} className="mb-3 flex-row justify-between rounded-xl bg-white p-4"><Text>{c.nombre}</Text><Pressable onPress={() => void restaurar("categoria", c.id)}><Text className="text-[--color-primary]">Restaurar</Text></Pressable></View>)}
      <Text className="mb-3 mt-5 text-xl font-semibold">Productos</Text>
      {platos.length === 0 ? <Text>No hay productos eliminados.</Text> : platos.map(p => <View key={p.id} className="mb-3 flex-row justify-between rounded-xl bg-white p-4"><Text>{p.nombre}</Text><Pressable onPress={() => void restaurar("plato", p.id)}><Text className="text-[--color-primary]">Restaurar</Text></Pressable></View>)}
    </ScrollView>}
  </View>;
}
