import { Tabs } from "expo-router";

import { TabIcon } from "@/components/navigation/tab-icon";
import { puedeVerPestana, type PestanaPrincipal } from "@/navigation/tabs";
import { useSesion } from "@/auth/session-context";

type TabConfig = {
  etiqueta: string;
  pestana: PestanaPrincipal;
};

const configuracionTabs: Record<PestanaPrincipal, TabConfig> = {
  carta: { etiqueta: "Carta", pestana: "carta" },
  mesas: { etiqueta: "Mesas", pestana: "mesas" },
  perfil: { etiqueta: "Perfil", pestana: "perfil" },
  personal: { etiqueta: "Personal", pestana: "personal" },
};

const ordenTabs: readonly PestanaPrincipal[] = ["mesas", "carta", "personal", "perfil"];

export default function TabsLayout() {
  const { sesion } = useSesion();
  const rol = sesion?.rol;

  return <Tabs screenOptions={{
    headerShown: false,
    tabBarActiveTintColor: "#1eab64",
    tabBarInactiveTintColor: "#6b6b67",
    tabBarStyle: { borderTopColor: "#e7e3d9", backgroundColor: "#fbfaf7" },
  }}>
    {ordenTabs.map((nombre) => {
      const configuracion = configuracionTabs[nombre];
      const visible = rol ? puedeVerPestana(rol, nombre) : false;

      return <Tabs.Screen key={nombre} name={nombre} options={{
        href: visible ? undefined : null,
        tabBarIcon: ({ focused }) => <TabIcon activa={focused} accessibilityLabel={`Ir a ${configuracion.etiqueta}`} pestana={configuracion.pestana} />,
        title: configuracion.etiqueta,
      }} />;
    })}
  </Tabs>;
}
