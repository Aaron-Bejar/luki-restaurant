import { puedeVerPestana, pestanasPermitidas } from "./tabs";

describe("pestañas principales por rol", () => {
  it("muestra todas las áreas al owner", () => {
    expect(pestanasPermitidas("owner")).toEqual(["mesas", "carta", "personal", "perfil"]);
  });

  it("oculta Personal a una mesera", () => {
    expect(pestanasPermitidas("waitress")).toEqual(["mesas", "carta", "perfil"]);
    expect(puedeVerPestana("waitress", "personal")).toBe(false);
  });
});
