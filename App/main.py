import tkinter as tk
from tkinter import ttk, messagebox
import psycopg2
import random
import hashlib
from PIL import Image, ImageTk, ImageDraw

DB = {
    'dbname': 'PM.05 DB',
    'user': 'postgres',
    'password': '2006',
    'host': 'localhost',
    'port': 5432
}

DB = {
    'dbname': 'PM.05 DB',
    'user': 'postgres',
    'password': '2006',
    'host': 'localhost',
    'port': 5432
}


def db_query(query, params=None, commit=False):
    conn = psycopg2.connect(**DB)
    cur = conn.cursor()
    cur.execute(query, params or ())
    if commit:
        conn.commit()
    result = cur.fetchall() if not commit else None
    cur.close()
    conn.close()
    return result


def init_db():
    db_query("""
        CREATE TABLE IF NOT EXISTS roles (
            id SERIAL PRIMARY KEY,
            role_name VARCHAR(20) NOT NULL UNIQUE
        )
    """, commit=True)

    for role_name in ('admin', 'user'):
        db_query("""
            INSERT INTO roles (role_name) VALUES (%s)
            ON CONFLICT (role_name) DO NOTHING
        """, (role_name,), commit=True)

    db_query("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            role INTEGER NOT NULL,
            locked BOOLEAN DEFAULT FALSE,
            failed_attempts INTEGER DEFAULT 0,
            FOREIGN KEY (role) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE RESTRICT
        )
    """, commit=True)

    if not db_query("SELECT id FROM users WHERE username = 'admin'"):
        admin_role_id = db_query("SELECT id FROM roles WHERE role_name = 'admin'")[0][0]
        hashed = hashlib.sha256('admin123'.encode()).hexdigest()
        db_query("""
            INSERT INTO users (username, password, role)
            VALUES (%s, %s, %s)
        """, ('admin', hashed, admin_role_id), commit=True)

def find_user(username):
    rows = db_query("""
        SELECT u.id, u.username, r.role_name, u.locked
        FROM users u
        JOIN roles r ON u.role = r.id
        WHERE u.username = %s
    """, (username,))
    return rows[0] if rows else None

def authenticate(username, password):
    rows = db_query("""
        SELECT u.id, u.username, r.role_name, u.locked, u.password
        FROM users u
        JOIN roles r ON u.role = r.id
        WHERE u.username = %s
    """, (username,))
    if not rows:
        return None
    user_id, uname, role, locked, hashed = rows[0]
    if locked:
        return None
    if hashlib.sha256(password.encode()).hexdigest() != hashed:
        db_query("UPDATE users SET failed_attempts = failed_attempts + 1 WHERE id = %s", (user_id,), commit=True)
        attempts = db_query("SELECT failed_attempts FROM users WHERE id = %s", (user_id,))[0][0]
        if attempts >= 3:
            db_query("UPDATE users SET locked = TRUE WHERE id = %s", (user_id,), commit=True)
        return None
    else:
        db_query("UPDATE users SET failed_attempts = 0 WHERE id = %s", (user_id,), commit=True)
        return (user_id, uname, role, locked)


def get_all_users():
    return db_query("""
        SELECT u.id, u.username, r.role_name, u.locked
        FROM users u
        JOIN roles r ON u.role = r.id
        ORDER BY u.id
    """)


def get_all_roles():
    return db_query("SELECT id, role_name FROM roles ORDER BY id")


def add_user(username, password, role_name):
    if db_query("SELECT id FROM users WHERE username = %s", (username,)):
        raise ValueError("Пользователь с таким логином уже существует")

    role_id = db_query("SELECT id FROM roles WHERE role_name = %s", (role_name,))
    if not role_id:
        raise ValueError("Указанная роль не найдена")

    hashed = hashlib.sha256(password.encode()).hexdigest()
    db_query("""
        INSERT INTO users (username, password, role)
        VALUES (%s, %s, %s)
    """, (username, hashed, role_id[0][0]), commit=True)


def update_user(user_id, password=None, role_name=None):
    if password:
        hashed = hashlib.sha256(password.encode()).hexdigest()
        db_query("UPDATE users SET password = %s WHERE id = %s", (hashed, user_id), commit=True)
    if role_name:
        role_id = db_query("SELECT id FROM roles WHERE role_name = %s", (role_name,))
        if not role_id:
            raise ValueError("Указанная роль не найдена")
        db_query("UPDATE users SET role = %s WHERE id = %s", (role_id[0][0], user_id), commit=True)


def unlock_user(user_id):
    db_query("UPDATE users SET locked = FALSE, failed_attempts = 0 WHERE id = %s", (user_id,), commit=True)


def delete_user(user_id):
    db_query("DELETE FROM users WHERE id = %s", (user_id,), commit=True)

class Puzzle(tk.Frame):
    def __init__(self, parent, size=300):
        super().__init__(parent)
        self.size = size
        self.cell = size // 2
        self.images = []
        for i in range(1, 5):
            try:
                img = Image.open(f"{i}.png").resize((self.cell, self.cell), Image.Resampling.LANCZOS)
                self.images.append(ImageTk.PhotoImage(img))
            except:
                img = Image.new('RGB', (self.cell, self.cell), 'gray')
                ImageDraw.Draw(img).text((10,10), str(i), fill='white')
                self.images.append(ImageTk.PhotoImage(img))
        self.correct = [0,1,2,3]
        self.order = self.correct.copy()
        random.shuffle(self.order)
        self.selected = None
        self.canvas = tk.Canvas(self, width=size, height=size, bg='white')
        self.canvas.pack()
        self.canvas.bind('<Button-1>', self.on_click)
        self.draw()

    def draw(self):
        self.canvas.delete('all')
        for i in range(4):
            r, c = divmod(i, 2)
            x, y = c*self.cell, r*self.cell
            self.canvas.create_image(x, y, anchor='nw', image=self.images[self.order[i]])
        self.canvas.create_line(self.cell, 0, self.cell, self.size, fill='black')
        self.canvas.create_line(0, self.cell, self.size, self.cell, fill='black')
        if self.selected is not None:
            r, c = divmod(self.selected, 2)
            x, y = c*self.cell, r*self.cell
            self.canvas.create_rectangle(x, y, x+self.cell, y+self.cell, outline='red', width=3)

    def on_click(self, e):
        col, row = e.x // self.cell, e.y // self.cell
        if not (0 <= col < 2 and 0 <= row < 2):
            return
        idx = row*2 + col
        if self.selected is None:
            self.selected = idx
            self.draw()
        else:
            self.order[self.selected], self.order[idx] = self.order[idx], self.order[self.selected]
            self.selected = None
            self.draw()

    def is_solved(self):
        return self.order == self.correct

    def reset(self):
        self.selected = None
        self.order = self.correct.copy()
        random.shuffle(self.order)
        self.draw()

class AdminWin(tk.Toplevel):
    def __init__(self, parent, current):
        super().__init__(parent)
        self.current = current
        self.title(f"Администратор - {current[1]}")
        self.geometry("600x400")
        self.minsize(500, 300)
        self.tree = ttk.Treeview(self, columns=('id', 'login', 'role', 'locked'), show='headings')
        self.tree.heading('id', text='ID')
        self.tree.heading('login', text='Логин')
        self.tree.heading('role', text='Роль')
        self.tree.heading('locked', text='Заблок.')
        self.tree.column('id', width=50)
        self.tree.column('login', width=150)
        self.tree.column('role', width=100)
        self.tree.column('locked', width=80)
        self.tree.pack(fill='both', expand=True, padx=10, pady=10)
        btn = ttk.Frame(self)
        btn.pack(pady=10)
        ttk.Button(btn, text="Добавить", command=self.add).pack(side='left', padx=5)
        ttk.Button(btn, text="Редактировать", command=self.edit).pack(side='left', padx=5)
        ttk.Button(btn, text="Разблокировать", command=self.unlock).pack(side='left', padx=5)
        ttk.Button(btn, text="Удалить", command=self.delete).pack(side='left', padx=5)
        ttk.Button(btn, text="Выйти", command=self.logout).pack(side='left', padx=5)
        self.refresh()

    def refresh(self):
        for i in self.tree.get_children():
            self.tree.delete(i)
        for u in get_all_users():
            locked = "Да" if u[3] else "Нет"
            self.tree.insert('', 'end', values=(u[0], u[1], u[2], locked))

    def add(self):
        d = tk.Toplevel(self)
        d.title("Добавить пользователя")
        d.geometry("300x200")
        ttk.Label(d, text="Логин:").grid(row=0, column=0, padx=5, pady=5, sticky='e')
        e1 = ttk.Entry(d);
        e1.grid(row=0, column=1, padx=5, pady=5)
        ttk.Label(d, text="Пароль:").grid(row=1, column=0, padx=5, pady=5, sticky='e')
        e2 = ttk.Entry(d, show='*');
        e2.grid(row=1, column=1, padx=5, pady=5)
        ttk.Label(d, text="Роль:").grid(row=2, column=0, padx=5, pady=5, sticky='e')

        # Получаем список ролей из БД
        roles = [r[1] for r in get_all_roles()]
        c = ttk.Combobox(d, values=roles, state='readonly')
        c.set('user' if 'user' in roles else roles[0] if roles else '')
        c.grid(row=2, column=1, padx=5, pady=5)

        def save():
            try:
                add_user(e1.get().strip(), e2.get(), c.get())
                messagebox.showinfo("Успех", "Добавлен")
                d.destroy()
                self.refresh()
            except ValueError as e:
                messagebox.showerror("Ошибка", str(e))

        ttk.Button(d, text="Сохранить", command=save).grid(row=3, column=0, columnspan=2, pady=10)

    def edit(self):
        sel = self.tree.selection()
        if not sel:
            messagebox.showwarning("Предупреждение", "Выберите пользователя")
            return
        uid = self.tree.item(sel[0])['values'][0]
        row = db_query("""
            SELECT u.username, r.role_name
            FROM users u
            JOIN roles r ON u.role = r.id
            WHERE u.id = %s
        """, (uid,))
        if not row:
            return
        uname, role = row[0]
        d = tk.Toplevel(self)
        d.title("Редактировать пользователя")
        d.geometry("300x250")

        ttk.Label(d, text="Логин:").grid(row=0, column=0, padx=5, pady=5, sticky='e')
        ttk.Label(d, text=uname).grid(row=0, column=1, padx=5, pady=5, sticky='w')

        ttk.Label(d, text="Новый пароль (оставьте пустым, если не меняется):").grid(
            row=1, column=0, columnspan=2, padx=5, pady=5)
        pass_entry = ttk.Entry(d, show='*')
        pass_entry.grid(row=2, column=0, columnspan=2, padx=5, pady=5)

        ttk.Label(d, text="Роль:").grid(row=3, column=0, padx=5, pady=5, sticky='e')
        roles = [r[1] for r in get_all_roles()]
        role_combo = ttk.Combobox(d, values=roles, state='readonly')
        role_combo.set(role)
        role_combo.grid(row=3, column=1, padx=5, pady=5)

        def save():
            new_pass = pass_entry.get()
            new_role = role_combo.get()
            if not new_pass and new_role == role:
                messagebox.showinfo("Инфо", "Нет изменений")
                d.destroy()
                return
            try:
                update_user(uid, new_pass if new_pass else None, new_role)
                messagebox.showinfo("Успех", "Обновлено")
                d.destroy()
                self.refresh()
            except ValueError as e:
                messagebox.showerror("Ошибка", str(e))

        ttk.Button(d, text="Сохранить", command=save).grid(row=4, column=0, columnspan=2, pady=10)

    def unlock(self):
        sel = self.tree.selection()
        if not sel:
            messagebox.showwarning("Предупреждение", "Выберите пользователя")
            return
        uid = self.tree.item(sel[0])['values'][0]
        unlock_user(uid)
        messagebox.showinfo("Успех", "Разблокирован")
        self.refresh()

    def delete(self):
        sel = self.tree.selection()
        if not sel:
            messagebox.showwarning("Предупреждение", "Выберите пользователя")
            return
        uid = self.tree.item(sel[0])['values'][0]
        if uid == self.current[0]:
            messagebox.showerror("Ошибка", "Нельзя удалить себя")
            return
        if messagebox.askyesno("Подтверждение", "Удалить пользователя?"):
            delete_user(uid)
            self.refresh()

    def logout(self):
        self.destroy()
        root.deiconify()

class UserWin(tk.Toplevel):
    def __init__(self, parent, username):
        super().__init__(parent)
        self.title(f"Пользователь - {username}")
        self.geometry("400x300")
        ttk.Label(self, text=f"Добро пожаловать, {username}!\nВаша роль: пользователь").pack(expand=True, pady=50)
        ttk.Button(self, text="Выйти", command=self.logout).pack(pady=20)

    def logout(self):
        self.destroy()
        root.deiconify()

class LoginWin(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Авторизация")
        self.geometry("500x600")
        self.minsize(450, 550)
        self.create()

    def create(self):

        f = ttk.LabelFrame(self, text="Данные пользователя")
        f.pack(padx=20, pady=10, fill='x')
        ttk.Label(f, text="Логин:").grid(row=0, column=0, padx=5, pady=5, sticky='e')
        self.user = ttk.Entry(f); self.user.grid(row=0, column=1, padx=5, pady=5, sticky='ew')
        ttk.Label(f, text="Пароль:").grid(row=1, column=0, padx=5, pady=5, sticky='e')
        self.passw = ttk.Entry(f, show='*'); self.passw.grid(row=1, column=1, padx=5, pady=5, sticky='ew')
        f.columnconfigure(1, weight=1)

        cf = ttk.LabelFrame(self, text="Соберите пазл из четырёх фрагментов")
        cf.pack(padx=20, pady=10, fill='both', expand=True)
        self.puzzle = Puzzle(cf)
        self.puzzle.pack(pady=10, expand=True)
        ttk.Button(cf, text="Новый пазл", command=self.puzzle.reset).pack(pady=5)

        ttk.Button(self, text="Войти", command=self.login).pack(side='bottom', pady=10)

    def login(self):
        username = self.user.get().strip()
        password = self.passw.get()
        if not username or not password:
            messagebox.showerror("Ошибка", "Заполните логин и пароль")
            return

        if not self.puzzle.is_solved():
            user = find_user(username)
            if user:
                uid = user[0]
                db_query("UPDATE users SET failed_attempts = failed_attempts + 1 WHERE id = %s", (uid,), commit=True)
                attempts = db_query("SELECT failed_attempts FROM users WHERE id = %s", (uid,))[0][0]
                if attempts >= 3:
                    db_query("UPDATE users SET locked = TRUE WHERE id = %s", (uid,), commit=True)
                    messagebox.showerror("Ошибка", "Вы заблокированы. Обратитесь к администратору.")
                else:
                    messagebox.showerror("Ошибка", "Пазл собран неверно. Попробуйте снова.")
            else:
                messagebox.showerror("Ошибка", "Неверный логин или пароль")
            self.puzzle.reset()
            return

        user = find_user(username)
        if user and user[3]:
            messagebox.showerror("Ошибка", "Вы заблокированы. Обратитесь к администратору.")
            self.puzzle.reset()
            return

        auth = authenticate(username, password)
        if not auth:
            messagebox.showerror("Ошибка", "Неверный логин или пароль")
            self.puzzle.reset()
            return

        messagebox.showinfo("Успех", "Вы успешно авторизовались")
        self.withdraw()
        if auth[2] == 'admin':
            AdminWin(self, auth)
        else:
            UserWin(self, auth[1])

if __name__ == "__main__":
    init_db()
    root = LoginWin()
    root.mainloop()