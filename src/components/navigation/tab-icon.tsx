import { Image } from "expo-image";
import type { ComponentProps } from "react";

import type { PestanaPrincipal } from "@/navigation/tabs";

const iconos: Record<PestanaPrincipal, number> = {
  mesas: require("../../../assets/icons/mesas.svg"),
  carta: require("../../../assets/icons/menu.svg"),
  personal: require("../../../assets/icons/meseras.svg"),
  perfil: require("../../../assets/icons/user.svg"),
};

type TabIconProps = Pick<ComponentProps<typeof Image>, "accessibilityLabel"> & {
  activa: boolean;
  pestana: PestanaPrincipal;
};

export function TabIcon({ activa, accessibilityLabel, pestana }: TabIconProps) {
  return <Image accessibilityLabel={accessibilityLabel} contentFit="contain" source={iconos[pestana]} style={{ height: 20, opacity: activa ? 1 : 0.55, width: 20 }} tintColor={activa ? "#1eab64" : "#6b6b67"} />;
}
