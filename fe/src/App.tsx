/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AppLayout } from "./layouts/AppLayout";
import { HomeScreen } from "./screens/HomeScreen";
import { SelectionScreen } from "./screens/SelectionScreen";
import { GuideScreen } from "./screens/GuideScreen";
import { AnalyzingScreen } from "./screens/AnalyzingScreen";
import { ResultScreen } from "./screens/ResultScreen";
import { HistoryScreen } from "./screens/HistoryScreen";
import { ProfileScreen } from "./screens/ProfileScreen";
import { PaywallScreen } from "./screens/PaywallScreen";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppLayout />}>
          <Route path="/" element={<HomeScreen />} />
          <Route path="/select" element={<SelectionScreen />} />
          <Route path="/guide/:id" element={<GuideScreen />} />
          <Route path="/analyzing/:id" element={<AnalyzingScreen />} />
          <Route path="/result/:status/:id" element={<ResultScreen />} />
          <Route path="/history" element={<HistoryScreen />} />
          <Route path="/profile" element={<ProfileScreen />} />
          <Route path="/paywall" element={<PaywallScreen />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
