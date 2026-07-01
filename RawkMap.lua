-- Исходные настройки
local MIN_SCALE = 1.0      -- Минимальный масштаб
local MAX_SCALE = 2.0      -- Максимальный масштаб
local SCALE_STEP = 0.05    -- Шаг изменения масштаба при одном прокруте колесика
local DEFAULT_SCALE = 1.35 -- Дефолтный масштаб, если аддон запущен впервые

-- Функция умной стабилизации координат карты и динамического сдвига баффов
local function UpdateMapGeometry()
    if MinimapCluster then
        -- 1. Корректируем масштаб и удерживаем карту строго в углу (-5, -5)
        MinimapCluster:SetScale(RawkMapScale)
        MinimapCluster:ClearAllPoints()
        MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5 / RawkMapScale, -5 / RawkMapScale)
        
        -- 2. Динамический сдвиг баффов Сируса влево в зависимости от текущего масштаба карты
        if TemporaryEnchantFrame then
            TemporaryEnchantFrame:ClearAllPoints()
            -- Привязываем правый край баффов к левому краю миникарты с безопасным зазором -15 пикселей
            TemporaryEnchantFrame:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", -15, -10)
        end
        
        if ConsolidatedBuffs then
            ConsolidatedBuffs:ClearAllPoints()
            ConsolidatedBuffs:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", -15, -10)
        end
    end
end

local frame = CreateFrame("Frame")
-- Регистрируем событие загрузки аддона для корректного восстановления сохраненных переменных
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RawkMap" then -- Укажите здесь точное имя папки вашего аддона
        -- Если сохраненного значения еще нет (первый запуск), выставляем дефолтное
        if not RawkMapScale then
            RawkMapScale = DEFAULT_SCALE
        end
        UpdateMapGeometry()
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Страховочное обновление геометрии при входе в мир/экране загрузки
        UpdateMapGeometry()
        
        -- Прошиваем динамическое масштабирование колесиком мыши
        Minimap:EnableMouseWheel(true)
        Minimap:SetScript("OnMouseWheel", function(self, delta)
            if delta > 0 then
                RawkMapScale = RawkMapScale + SCALE_STEP
                if RawkMapScale > MAX_SCALE then RawkMapScale = MAX_SCALE end
            else
                RawkMapScale = RawkMapScale - SCALE_STEP
                if RawkMapScale < MIN_SCALE then RawkMapScale = MIN_SCALE end
            end
            -- Применяем изменения «на лету»
            UpdateMapGeometry()
        end)
        
        -- Отписываемся от PLAYER_ENTERING_WORLD, чтобы скрипт не дублировал установку OnMouseWheel
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
