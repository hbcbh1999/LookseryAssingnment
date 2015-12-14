# LookseryAssingnment

In march 2015 [Looksery](https://www.looksery.com) interviewing me asked to make small app with following requrements (in Russian but I'll translate this into English the other day):

Создать приложение с двумя экранами.

Первый экран представляет из себе простой список состоящий их сохраненных данных (профилей пользователя) и кнопку добавления нового профиля.

При нажатии на ячейку/профиль, открывается экран профиля, у которого есть два режима - просмотра и редактирования.

Экран профиля должен быть реализован при помощи UITableView

Профиль состоит из следующих полей/ячеек.
1.	Аватар ( картинка которую можно изменить выбором из галереи)
2.	ФИО
3.	Дата рождения
4.	Пол
5.	Номера телефона (у пользователя должна быть возможность ввести более одного номера телефона, должна быть проведена проверка, что номер не содержит некорректные символы). Каждый номер представляет отдельную строчку таблицы.
6.	Поле “О себе”. Длина ограничена 256 символами. В случае если пользователь ввел хэштеги, они должны быть подсвечены красным. Например: “Я работаю в #looksery. Крутая компания :)”

После ввода всех данных у пользователя должна быть возможность сохранить профиль и перейти в режим просмотра.

При перезапуске приложения данные должны быть сохранены.

This project implements this.

Looksery refused me, but that doesn't matter too much.

Later I used this project as example project showing my students at [itstep](http://itstep.org/en/) some principles. Today instaed of removing this project from hard drive I've decided just make this project public here on GitHub.
