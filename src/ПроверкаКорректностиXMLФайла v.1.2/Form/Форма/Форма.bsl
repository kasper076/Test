﻿#Область Вспомогательные

&НаСервере
Процедура ЗарегистрироватьОшибку(УзелДОМ, ОписаниеОшибки, ОтсутсвующееСвойство = "")
	
	ПолноеИмяУзла = УзелДОМ.ИмяУзла + ?(ОтсутсвующееСвойство = "", "", "\" + ОтсутсвующееСвойство);
	РодительскийУзел = УзелДОМ.РодительскийУзел;
	Пока РодительскийУзел.ИмяУзла <> "#document" Цикл
		МассивСтрок = Новый Массив;
		МассивСтрок.Добавить(РодительскийУзел.ИмяУзла);
		МассивСтрок.Добавить("\");
		МассивСтрок.Добавить(ПолноеИмяУзла);
		ПолноеИмяУзла = СтрСоединить(МассивСтрок);
		РодительскийУзел = РодительскийУзел.РодительскийУзел;
	КонецЦикла;
	
	ГУИД = Строка(Новый УникальныйИдентификатор);
	
	Атрибут = УзелДОМ.ДокументВладелец.СоздатьАтрибут("Error");
	Атрибут.Значение = СокрЛП(ГУИД);
	УзелДОМ.Атрибуты.УстановитьИменованныйЭлемент(Атрибут);
	
	СтрокаТаблицы = ТаблицаОшибок.Добавить();
	СтрокаТаблицы.ИД = ГУИД;
	СтрокаТаблицы.Реквизит = ПолноеИмяУзла;
	СтрокаТаблицы.Значение = УзелДОМ.ИмяУзла;
	СтрокаТаблицы.Описание = ОписаниеОшибки;
	
КонецПроцедуры

&НаСервере
Процедура АктивироватьЭлементТекст()
	ЭтаФорма.ТекущийЭлемент = Элементы.ТекстовыйДокумент;
КонецПроцедуры

#КонецОбласти

#Область СобытияФормы

#Область ОбработчикиАсинхронныхВызовов

&НаКлиенте
Процедура ИмяФайлаПакетаНачалоВыбораПослеПодключенияРасширения(Подключено, ПараметрыОповещения) Экспорт
	
	Если Подключено Тогда
		ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
		ДиалогОткрытияФайла.Заголовок = НСтр("ru = 'Выберите файл пакета'");
		ДиалогОткрытияФайла.Фильтр = "Файл пакета (*.xml)|*.xml";
		ДиалогОткрытияФайла.Показать(Новый ОписаниеОповещения("ИмяФайлаПакетаНачалоВыбораПослеДиалогаВыбораФайла", ЭтаФорма));
		
	Иначе // веб-клиент без расширение
		
		ПоказатьПредупреждение(, НСтр("ru = 'Для выбора каталога в веб-клиенте необходимо установить расширение для работы с файлами.'"));
		
	КонецЕсли;	
	
КонецПроцедуры	

&НаКлиенте
Процедура ИмяФайлаПакетаНачалоВыбораПослеДиалогаВыбораФайла(ВыбранныеФайлы, ПараметрыОповещения) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		ИмяФайла = ВыбранныеФайлы[0];
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПакетПослеПомещенияФайлов(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	ТаблицаОшибок.Очистить();
	ПроверитьНаСервере(Адрес);
	Сообщить(НСтр("ru = 'Проверка пакета завершена.'"));
	
КонецПроцедуры // ЗагрузитьПакетыПослеПомещенияФайлов()

#КонецОбласти

&НаКлиенте
Процедура ИмяФайлаПакетаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
		
	СтандартнаяОбработка = Ложь;
	НачатьПодключениеРасширенияРаботыСФайлами(Новый ОписаниеОповещения("ИмяФайлаПакетаНачалоВыбораПослеПодключенияРасширения", ЭтаФорма));

КонецПроцедуры

&НаКлиенте
Процедура ТаблицаОшибокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	АктивироватьЭлементТекст();
	Элементы.ТекстовыйДокумент.УстановитьГраницыВыделения(Элемент.ТекущиеДанные.Закладка, Элемент.ТекущиеДанные.Закладка);
	
КонецПроцедуры

#КонецОбласти

#Область Прикладные

&НаСервере
Процедура ПроверитьНаСервере(АдресПроверяемогоПакета)
	
	#Область ЧтениеДокументаДОМ
	//Читаем файл из временного хранилища
	Поток = ПолучитьИзВременногоХранилища(АдресПроверяемогоПакета).ОткрытьПотокДляЧтения();
	ЧтениеХМЛ = Новый ЧтениеXML;
	ЧтениеХМЛ.ОткрытьПоток(Поток);
	ПостроительДОМ = Новый ПостроительDOM;
	Попытка
		ДокументДОМ	= ПостроительДОМ.Прочитать(ЧтениеХМЛ);
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	ЧтениеХМЛ.Закрыть();
	Поток.Закрыть();
	#КонецОбласти
	
	#Область ОбходДереваДОМ
	//Обходим дерево ДОМ
	ОбходДереваDOM = Новый ОбходДереваDOM(ДокументДОМ);
	//Получаем корневой узел
	ОбходДереваDOM.СледующийУзел();
	//Получаем тип корневого узла
	//ТипОбъектаXDTO = ФабрикаXDTO.Тип("http://www.MyURL", "MyObject");
	ТипОбъектаXDTO = ФабрикаXDTO.Тип("http://www.rosneft.ru/GasComplex/Retail", "GC-ERPRN");
	//Получаем первый вложенный узел
	УзелDOM = ОбходДереваDOM.СледующийУзел();
	Пока УзелDOM <> Неопределено Цикл

		#Область ПоискСвойстваОбъектаXDTOПоЛокальномуИмениУзла
		СвойствоОбъектаXDTO = Неопределено;
		Для Каждого СвойствоXDTO Из ТипОбъектаXDTO.Свойства Цикл
			Если СвойствоXDTO.ЛокальноеИмя = УзелDOM.ИмяУзла Тогда
				//СвойствоТипОбъектаXDTO = ФабрикаXDTO.Тип(СвойствоXDTO.Тип.URIПространстваИмен, СвойствоXDTO.Тип.Имя);
				СвойствоОбъектаXDTO = СвойствоXDTO;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если СвойствоОбъектаXDTO = Неопределено Тогда
			Сообщить("Объект " + УзелDOM.РодительскийУзел.ИмяУзла + " неивестное свойство " + УзелDOM.ИмяУзла);
			УзелDOM = ОбходДереваDOM.СледующийСоседний();
			Продолжить;
		КонецЕсли;
		#КонецОбласти
		
		ПроверитьУзел(УзелDOM, СвойствоОбъектаXDTO.Тип);
		
		//Получаем следующий узел на этом же уровне вложенности
		УзелDOM = ОбходДереваDOM.СледующийСоседний();
	КонецЦикла;
	#КонецОбласти
	
	#Область ЗаписьДокументаДОМ
	//Записываем документ ДОМ в поток
	Поток = Новый ПотокВПамяти ;
	ЗаписьХМЛ = Новый ЗаписьXML;
	ЗаписьХМЛ.Отступ = Истина;
	ЧетыреПробела = "    ";
	ПараметрыЗаписи = Новый ПараметрыЗаписиXML("UTF-8", , Истина, Ложь, ЧетыреПробела);
	ЗаписьХМЛ.ОткрытьПоток(Поток, ПараметрыЗаписи);
	ЗаписьДОМ = Новый ЗаписьDOM;
	ЗаписьДОМ.Записать(ДокументДОМ, ЗаписьХМЛ);
	ЗаписьХМЛ.Закрыть();
	#КонецОбласти
	
	ПозицияКурсора = 0;
	Смещение	   = 0;
	
	//Закрываем Поток для записи и открываем для чтения
	Поток = Поток.ЗакрытьИПолучитьДвоичныеДанные().ОткрытьПотокДляЧтения();
	//Читаем текст документа ДОМ из потока
	ТекстовыйДокумент.Прочитать(Поток);
	Поток.Закрыть();
	Для НомерСтроки = 1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
		ТекстСтроки = ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки);
		Для Каждого СтрокаТаблицыОшибок Из ТаблицаОшибок Цикл
			Если  СтрокаТаблицыОшибок.Обработана Или СтрНайти(ТекстСтроки, СтрокаТаблицыОшибок.ИД) = 0 Тогда
				Продолжить;
			КонецЕсли;
			СтрокаТаблицыОшибок.Номер	   = НомерСтроки;
			СтрокаТаблицыОшибок.Обработана = Истина;
			СтрокаТаблицыОшибок.Закладка   = ПозицияКурсора + 1 + СтрДлина(ТекстСтроки) - СтрДлина(СокрЛП(ТекстСтроки)) - Смещение;
			
			Смещение = Смещение + СтрДлина("Error=""""00000000-0000-0000-0000-000000000000""");
			
			ТекстовыйДокумент.ЗаменитьСтроку(НомерСтроки, СтрЗаменить(ТекстСтроки, " Error=""" + СтрокаТаблицыОшибок.ИД + """", "")); 
		КонецЦикла;
		ПозицияКурсора = ПозицияКурсора + СтрДлина(ТекстСтроки) + 1;
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьУзел(УзелDOM, ТипXDTO)
	
	//Пытаемся прочитать УзелDOM ФабрикойXDTO
	УзелКорректный = Истина;
	
	#Область ЧтениеУзловДОМ
	ЧтениеУзловDOM = Новый ЧтениеУзловDOM;
	ЧтениеУзловDOM.Открыть(УзелDOM);
	//Фабрика = ФабрикаXDTO.ПрочитатьXML(ЧтениеУзловDOM, ТипXDTO);
	Попытка
		Фабрика = ФабрикаXDTO.ПрочитатьXML(ЧтениеУзловDOM, ТипXDTO);
	Исключение
		УзелКорректный = Ложь;
	КонецПопытки;
	ЧтениеУзловDOM.Закрыть();
	#КонецОбласти
	
	//Если узел корректный, выходим из рекурсии
	Если УзелКорректный Тогда
		Возврат;
	КонецЕсли;
	//Если это свойство содержащее простое значение, значит оно некорректное
	Если ТипЗнч(УзелDOM.ПервыйДочерний) = Тип("ТекстDOM") Или ТипЗнч(ТипXDTO) = Тип("ТипЗначенияXDTO") Тогда
		ТекстСообщения = "Узел """ + УзелDOM.ИмяУзла + """ (тип """ +  ТипXDTO.Имя + """) содержит некорректное значение """ + УзелDOM.ТекстовоеСодержимое + """";
		ЗарегистрироватьОшибку(УзелDOM, ТекстСообщения); 
	//Есть вложенные, а их быть не должно	
	ИначеЕсли УзелDOM.ЕстьДочерниеУзлы() И ТипXDTO.Свойства.Количество() = 0 Тогда
		ТекстСообщения = "Узел """ + УзелDOM.ИмяУзла + """ не должен содержать вложенных секций.";
		ЗарегистрироватьОшибку(УзелDOM, ТекстСообщения);
	//Не вложенных, а они должны быть
	ИначеЕсли Не УзелDOM.ЕстьДочерниеУзлы() И ТипXDTO.Свойства.Количество() <> 0 Тогда
		ТекстСообщения = "Узел """ + УзелDOM.РодительскийУзел.ИмяУзла + """ содержит пустую секцию """ + УзелDOM.ИмяУзла + """";
		ЗарегистрироватьОшибку(УзелDOM, ТекстСообщения);
	Иначе
		//Получаем свойства соответствующего ТипаXDTO
		УзелDOMСвойстваXDTO = Новый ТаблицаЗначений;
		УзелDOMСвойстваXDTO.Колонки.Добавить("ТипXDTO");
		УзелDOMСвойстваXDTO.Колонки.Добавить("ЛокальноеИмя",   Новый ОписаниеТипов("Строка"));
		УзелDOMСвойстваXDTO.Колонки.Добавить("Существует",	   Новый ОписаниеТипов("Булево"));
		УзелDOMСвойстваXDTO.Колонки.Добавить("НеОбязательное", Новый ОписаниеТипов("Булево"));
		Для Каждого СвойствоТипаXDTO Из ТипXDTO.Свойства Цикл
			НоваяСтрока = УзелDOMСвойстваXDTO.Добавить();
			НоваяСтрока.ТипXDTO			= СвойствоТипаXDTO.Тип;
			НоваяСтрока.ЛокальноеИмя	= СвойствоТипаXDTO.ЛокальноеИмя;
			НоваяСтрока.Существует		= Ложь;
			НоваяСтрока.НеОбязательное	= СвойствоТипаXDTO.НижняяГраница = 0;
		КонецЦикла;
		//Проверяем наличие свойств
		Для Каждого Дочерний Из УзелDOM.ДочерниеУзлы Цикл
			СвойствоТипаXDTO = УзелDOMСвойстваXDTO.Найти(Дочерний.ИмяУзла, "ЛокальноеИмя"); 
			Если СвойствоТипаXDTO <> Неопределено Тогда
				СвойствоТипаXDTO.Существует = Истина;
				ПроверитьУзел(Дочерний, СвойствоТипаXDTO.ТипXDTO);
			Иначе
				ТекстСообщения = "Узел """ + УзелDOM.ИмяУзла + """ содержит недопустимую вложенную секцию """ + Дочерний.ИмяУзла + """";
				ЗарегистрироватьОшибку(Дочерний, ТекстСообщения); 
			КонецЕсли;	
		КонецЦикла;
		ОтсутствующиеСвойства = УзелDOMСвойстваXDTO.НайтиСтроки(Новый Структура("Существует, НеОбязательное", Ложь, Ложь));
		Для Каждого ОтсутствующееСвойство Из ОтсутствующиеСвойства Цикл
			ТекстСообщения = "Отсутствует обязательная вложенная секция """ + ОтсутствующееСвойство.ЛокальноеИмя + """";
			ЗарегистрироватьОшибку(УзелDOM, ТекстСообщения, ОтсутствующееСвойство.ЛокальноеИмя);
		КонецЦикла;
		Если ТипXDTO.Упорядоченный Тогда
			ТекущийИндексСвойства = 0;
			Для Каждого Дочерний Из УзелDOM.ДочерниеУзлы Цикл
				Если ТекущийИндексСвойства > ТипXDTO.Свойства.Количество() - 1 Тогда
					Прервать;
				КонецЕсли;
				Продолжать = Истина;
				Пока Продолжать Цикл
					СвойствоТипаXDTO = ТипXDTO.Свойства.Получить(ТекущийИндексСвойства);
					ТекущийИндексСвойства = ТекущийИндексСвойства + 1;
					Если СвойствоТипаXDTO.ЛокальноеИмя = Дочерний.ИмяУзла Тогда
						Прервать;
					КонецЕсли;
					Если ТекущийИндексСвойства > ТипXDTO.Свойства.Количество() - 1 Тогда
						Продолжать = Ложь;
						Прервать;
					КонецЕсли;
					Если СвойствоТипаXDTO.НижняяГраница = 0 Тогда
						Продолжить;
					КонецЕсли;
					Продолжать = Ложь;
				КонецЦикла;	
				Если Не Продолжать Тогда
					ТекстСообщения = "Дочерний узел """ + Дочерний.ИмяУзла + """ узла """ + УзелDOM.ИмяУзла + """ имеет некорректную последовательнсть.";
					ЗарегистрироватьОшибку(Дочерний, ТекстСообщения, СвойствоТипаXDTO.ЛокальноеИмя);
					Прервать;
				КонецЕсли;	
			КонецЦикла;
		КонецЕсли;	
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура Проверить(Команда)
	
	// Помещение файлов во временное хранилище
	НачатьПомещениеФайла(Новый ОписаниеОповещения("ПроверитьПакетПослеПомещенияФайлов", ЭтотОбъект), , ИмяФайла, Ложь, УникальныйИдентификатор);
	
КонецПроцедуры

#КонецОбласти

