import { Redirect, type Href } from "expo-router";
import { ActivityIndicator, View } from "react-native";

import { useSesion } from "@/auth/session-context";

export default function IndexRoute() {
  const { cargandoSesion, sesion } = useSesion();

  if (cargandoSesion) {
    return (
      <View className="flex-1 items-center justify-center bg-[--color-surface]">
        <ActivityIndicator color="#1eab64" />
      </View>
    );
  }

  return <Redirect href={(sesion ? "/(app)" : "/(auth)") as Href} />;
}
