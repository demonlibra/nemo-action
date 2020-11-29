#!/bin/bash

#Проверка установки пакета yad
if [ -z "`dpkg -l | grep yad`" ]
	then gnome-terminal --hide-menubar --geometry=80x15 -t "Установка пакета yad" -- bash -c "echo \"yad не установлен\"; echo ; sudo apt install yad; echo ; echo ------------------ ; echo ; echo \"Установка yad завершена\"; echo ; read -p \"Нажмите ENTER чтобы закрыть окно\""
fi

#Проверка установки пакета openSCAD
if [ -z "`dpkg -l | grep openscad`" ]
	then gnome-terminal --hide-menubar --geometry=80x15 -t "Установка пакета openscad" -- bash -c "echo \"openscad не установлен\"; echo ; sudo apt install openscad; echo ; echo ------------------ ; echo ; echo \"Установка openscad завершена\"; echo ; read -p \"Нажмите ENTER чтобы закрыть окно\""
fi

#Проверка установки пакета apngasm
if [ -z "`dpkg -l | grep apngasm`" ]
	then gnome-terminal --hide-menubar --geometry=80x15 -t "Установка пакета apngasm" -- bash -c "echo \"apngasm не установлен\"; echo ; sudo apt install apngasm; echo ; echo ------------------ ; echo ; echo \"Установка apngasm завершена\"; echo ; read -p \"Нажмите ENTER чтобы закрыть окно\""
fi

AAA=`yad --borders=10 --title="stl 2 apng" --text="Создание анимации из stl" --text-align=center --form --item-separator="|" --field=:LBL --field="Ширина изображения" --field="Высота изображения" --field="Проекция:CB" --field="Смещение вдоль осей" --field="Автоцентровка:CHK" --field="Отдаление от модели" --field="Вписать модель в размер:CHK" --field="Начальный угол оси X" --field="Начальный угол оси Y" --field="Начальный угол оси Z" --field="Угол поворота оси Z за шаг" --field="Задержка анимации(1/5 сек)"  "" 1080 1080  "ortho|perspective" "0,0,0" TRUE "500" TRUE 40 0 40 30 "1 5"`

if [ $? = 0 ]
	then
		width=$( echo $AAA | awk -F '|' '{print $2}')
		height=$( echo $AAA | awk -F '|' '{print $3}')

		projection=$( echo $AAA | awk -F '|' '{print $4}')

		trans=$( echo $AAA | awk -F '|' '{print $5}')
		autocenter=$( echo $AAA | awk -F '|' '{print $6}')
		if [ $autocenter = "TRUE" ]; then autocenter='--autocenter'; else autocenter=''; fi

		distance=$( echo $AAA | awk -F '|' '{print $7}')
		viewall=$( echo $AAA | awk -F '|' '{print $8}')
		if [ $viewall = "TRUE" ]; then viewall='--viewall'; else viewall=''; fi

		rotx=$( echo $AAA | awk -F '|' '{print $9}')
		roty=$( echo $AAA | awk -F '|' '{print $10}')
		rotz_start=$( echo $AAA | awk -F '|' '{print $11}')
		degree_step=$( echo $AAA | awk -F '|' '{print $12}')
		delay=$( echo $AAA | awk -F '|' '{print $13}')

		for file in "$@"
			do
				#Создание временного файла scad с командой импорта stl
				echo "import(\"${file}\");" > "${file%.*}.scad"

				# Экспорт кадров в png при помощи openSCAD
				num=0
				for ((rotz=rotz_start; rotz<rotz_start+360; rotz=rotz+degree_step))
					do
						num=$((num+1))
						name="${file%/*}/frame"`printf "%02d" $num`".png"
						openscad -o "$name" --camera=$trans,$rotx,$roty,$rotz,$distance --projection=$projection $autocenter $viewall --imgsize=$width,$height "${file%.*}.scad"
					done

                                # Объединение кадров в apng
				apngasm "${file%.*}.png" "${file%/*}/frame"*".png" $delay

				# Удаление кадров
				rm "${file%/*}/frame"*".png"

				# Удаление временного файла scad
				rm "${file%.*}.scad"
			done
fi