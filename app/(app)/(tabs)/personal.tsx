import { Redirect, type Href } from "expo-router";
import { Text, View } from "react-native";

import { useSesion } from "@/auth/session-context";

export default function PersonalScreen() {
  const { sesion } = useSesion();

  if (sesion?.rol !== "owner") return <Redirect href={"/(app)/(tabs)/mesas" as Href} />;

  return <View className="flex-1 bg-[--color-surface] px-6 py-12"><Text className="text-3xl font-bold text-[--color-ink]">Personal</Text></View>;
}
